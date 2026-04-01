extends Node

@onready var object_file_dialog: FileDialog = %ObjectFileDialog
@onready var config_file_dialog: FileDialog = %ConfigFileDialog

@onready var save_object_button: Button = %SaveObjectButton
@onready var start_simulation_button: Button = %StartSimulationButton

@onready var title_screen: CanvasLayer = %TitleScreen
@onready var map: Node2D = %Map
@onready var camera_2d: Camera2D = %Camera2D
@onready var current_time_label: Label = %CurrentTimeLabel
@onready var room_panel: PanelContainer = %RoomPanel
@onready var room_panel_text: RichTextLabel = %RoomPanelText

@export var generic_person_scene: PackedScene = preload("res://Entity/generic_person.tscn")
@export var infant_boy_scene: PackedScene = preload("res://Entity/Infant_Boy.tscn")
@export var infant_girl_scene: PackedScene = preload("res://Entity/Infant_Girl.tscn")
@export var toddler_boy_scene: PackedScene = preload("res://Entity/Toddler_Boy.tscn")
@export var toddler_girl_scene: PackedScene = preload("res://Entity/Toddler_Girl.tscn")
@export var preschooler_boy_scene: PackedScene = preload("res://Entity/Preschooler_Boy.tscn")
@export var preschooler_girl_scene: PackedScene = preload("res://Entity/Preschooler_Girl.tscn")
@export var careprovider_scene_1: PackedScene = preload("res://Entity/CareProvider1.tscn")
@export var careprovider_scene_2: PackedScene = preload("res://Entity/CareProvider2.tscn")
@onready var save_timer: Timer = %SaveTimer

@export var room_alert_threshold_vl: float = 400.0
@export var room_alert_check_interval_s: float = 45.0 * 60.0
@export var room_panel_refresh_interval_s: float = 0.5
@export var sim_speed_scale_step: float = 0.2
@export var sim_speed_scale_min: float = 0.05
@export var sim_speed_scale_max: float = 2.6

var room_nodes: Array[Room] = []
var selected_room_idx: int = -1
var room_vl_last: Dictionary = {}
var room_alert_last_eval_s: Dictionary = {}
var room_alert_active: Dictionary = {}
var room_budget_last_update_s: float = 0.0
var room_panel_next_update_s: float = 0.0

const ROOM_ACH_STEP: float = 1.0
const ROOM_VL_TREND_EPSILON: float = 0.01
const ROOM_BUDGET_UPDATE_INTERVAL_S: float = 60.0
const ROOM_VL_COLOR_POINTS := [
	{"value": 0.0, "color": Color("#44c96b")},
	{"value": 250.0, "color": Color("#ff9f1c")},
	{"value": 500.0, "color": Color("#e63946")},
	{"value": 1000.0, "color": Color("#cf4dff")}
]
const SIM_SPEED_STEP_MIN: float = 0.001

func _derive_room_output_path(sim_output_file: String) -> String:
	if sim_output_file.ends_with(".json"):
		return sim_output_file.trim_suffix(".json") + "_rooms.json"
	return sim_output_file + "_rooms.json"

func _derive_poison_output_path(person_output_file: String) -> String:
	if person_output_file.ends_with(".json"):
		return person_output_file.trim_suffix(".json") + "_poison.json"
	return person_output_file + "_poison.json"

func _scene_for_person(pd: Dictionary) -> PackedScene:
	var role := str(pd.get("role", "")).strip_edges()
	var pid := str(pd.get("pid", ""))
	var pid_num := int(pid) if pid.is_valid_int() else 0

	if role == "infants":
		return infant_boy_scene if pid_num % 2 == 1 else infant_girl_scene

	if role == "younger toddlers" or role == "older toddlers":
		return toddler_boy_scene if pid_num % 2 == 1 else toddler_girl_scene

	if role == "preschoolers":
		return preschooler_boy_scene if pid_num % 2 == 1 else preschooler_girl_scene

	if role == "providers" or role == "floaters":
		return careprovider_scene_1 if pid_num % 2 == 1 else careprovider_scene_2

	return generic_person_scene

func save_objects(file: String):
	print("Saving objects to file: ", file)
	var object_file = FileAccess.open(file, FileAccess.WRITE)
	var object_data = []
	for oid in Global.all_objects:
		var object = Global.all_objects[oid]
		object_data.append({
		"oid": object.get_path(),
		"type": object.type,
		"group": object.group,
		"pos_x": object.global_position[0],
		"pos_y": object.global_position[1]
	})
	var object_json = JSON.stringify(object_data)
	object_file.store_line(object_json)
	object_file.close()
	print("Saving objects complete.")

func create_persons(file: String):
	print("Creating persons from file: ", file)
	var person_file = FileAccess.open(file, FileAccess.READ)
	var person_data = JSON.parse_string(person_file.get_as_text())
	for pd in person_data:
		var scene_to_spawn := _scene_for_person(pd)
		if scene_to_spawn == null:
			print("Missing scene for person: ", JSON.stringify(pd))
			continue

		var person: Person = scene_to_spawn.instantiate()
		person.pid = str(pd.get("pid", ""))
		person.role = str(pd.get("role", ""))
		person.poison = float(pd.get("start_poison", 0))
		person.disease_state = str(pd.get("disease_state", "S"))
		add_child(person)
		person.hide()
		Global.all_persons[person.pid] = person
	print(len(Global.all_persons), " persons created")

func load_schedule(file: String):
	print("Loading schedules from file: ", file)
	var schedule_file = FileAccess.open(file, FileAccess.READ)
	var schedule_data = JSON.parse_string(schedule_file.get_as_text())

	var min_start_time: float = -1
	var max_start_time: float = -1

	for sd in schedule_data:
		var pid: String = sd["pid"]
		var aid: String = sd["aid"]
		var oid: String = _resolve_object_oid(str(sd["oid"]))
		var time: float = sd["start_time"]
		var activity_name: String = str(sd.get("activity", ""))
		var person: Person = Global.all_persons[pid]
		person.activity_aid.append(aid)
		person.activity_oid.append(oid)
		person.activity_name.append(activity_name)
		person.activity_time.append(time)

		if min_start_time == -1:
			min_start_time = time
		else:
			min_start_time = min(min_start_time, time)

		if max_start_time == -1:
			max_start_time = time
		else:
			max_start_time = max(max_start_time, time)

	Global.runtime_start_s = min_start_time
	Global.runtime_end_s = max_start_time + Global.max_activity_duration

	print("Loading schedules complete")
	print("Runtime start: ", Global.runtime_start_s)
	print("Runtime end: ", Global.runtime_end_s)

func _resolve_object_oid(raw_oid: String) -> String:
	if Global.all_objects.has(raw_oid):
		return raw_oid

	# Backward compatibility: older schedules used CubicleContainer path names.
	var cubicle_path_oid := raw_oid.replace("/CubicleContainer/", "/Cribs/")
	if Global.all_objects.has(cubicle_path_oid):
		return cubicle_path_oid

	# Last-resort fallback by node name, e.g. Cubicle20.
	var oid_name := raw_oid.get_file()
	for existing_oid in Global.all_objects:
		if str(existing_oid).get_file() == oid_name:
			return str(existing_oid)

	print("Missing object for schedule OID: ", raw_oid)
	return raw_oid

func load_config(file: String):
	print("Loading config from file: ", file)

	var config_file = FileAccess.open(file, FileAccess.READ)
	var config_data = JSON.parse_string(config_file.get_as_text())

	var person_file: String = config_data["person_file"]
	var schedule_file: String = config_data["schedule_file"]
	var person_output_file: String = str(config_data.get("person_output_file", config_data.get("output_file", "output_people.json")))
	var poison_output_file: String = str(config_data.get("poison_output_file", ""))
	var room_output_file: String = str(config_data.get("room_output_file", ""))
	var room_ach_file: String = str(config_data.get("room_ach_file", ""))

	if not person_file.is_absolute_path():
		person_file = file.get_base_dir().path_join(person_file)
	if not schedule_file.is_absolute_path():
		schedule_file = file.get_base_dir().path_join(schedule_file)
	if not person_output_file.is_absolute_path():
		person_output_file = file.get_base_dir().path_join(person_output_file)
	if poison_output_file == "":
		poison_output_file = _derive_poison_output_path(person_output_file)
	if not poison_output_file.is_absolute_path():
		poison_output_file = file.get_base_dir().path_join(poison_output_file)
	if room_output_file == "":
		room_output_file = _derive_room_output_path(person_output_file)
	if not room_output_file.is_absolute_path():
		room_output_file = file.get_base_dir().path_join(room_output_file)
	if room_ach_file != "" and not room_ach_file.is_absolute_path():
		room_ach_file = file.get_base_dir().path_join(room_ach_file)

	create_persons(person_file)
	load_schedule(schedule_file)
	Global.person_output_file_path = person_output_file
	Global.poison_output_file_path = poison_output_file
	Global.room_output_file_path = room_output_file

	var requested_sim_speed: float = float(config_data["sim_speed_scale"])
	_apply_sim_speed_scale(requested_sim_speed)
	Global.save_every_s = config_data["save_every_s"]

	Global.prob_poison_xfer = config_data["prob_poison_xfer"]
	Global.person_to_obj_coeff = config_data["person_to_obj_coeff"]
	Global.obj_to_person_coeff = config_data["obj_to_person_coeff"]
	Global.max_person_gain = config_data["max_person_gain"]
	Global.initial_poison = config_data["initial_poison"]

	Global.abs_tick_duration_s = config_data["abs_tick_duration_m"] * 60.0
	Global.abs_fast_poison_threshold = config_data["abs_fast_poison_threshold"]
	Global.abs_fast_rate_per_s = config_data["abs_fast_rate_per_h"] / 3600.0
	Global.abs_slow_frac_rate_per_s = config_data["abs_slow_frac_rate_per_h"] / 3600.0
	Global.abs_obj_absorption_frac = config_data["abs_obj_absorption_frac"]
	Global.room_ach_budget_start = float(config_data.get("room_ach_budget_start", 100.0))
	Global.room_ach_budget_remaining = Global.room_ach_budget_start
	Global.room_ach_cost_per_ach_hour = float(config_data.get("room_ach_cost_per_ach_hour", 5.0))

	if room_ach_file != "":
		load_room_ach_schedule(room_ach_file)

func load_room_ach_schedule(file: String):
	print("Loading room ACH schedule from file: ", file)
	var schedule_file = FileAccess.open(file, FileAccess.READ)
	var schedule_data = JSON.parse_string(schedule_file.get_as_text())

	if not schedule_data is Array:
		print("Room ACH schedule must be an array of rows")
		return

	for rid in Global.all_rooms:
		Global.all_rooms[rid].set_ach_schedule([])

	var rows_by_room: Dictionary = {}
	for row in schedule_data:
		if not row is Dictionary:
			continue

		var room_id := str(row.get("room_id", ""))
		if room_id == "":
			continue

		if not rows_by_room.has(room_id):
			rows_by_room[room_id] = []

		rows_by_room[room_id].append({
			"start_time": float(row.get("start_time", 0.0)),
			"ach": float(row.get("ach", 0.0))
		})

	for room_id in rows_by_room:
		if Global.all_rooms.has(room_id):
			Global.all_rooms[room_id].set_ach_schedule(rows_by_room[room_id])
		else:
			print("Room ACH schedule references unknown room_id: ", room_id)

	print("Loaded ACH rows for ", rows_by_room.size(), " rooms")

func start_simulation(file: String):
	load_config(file)

	title_screen.hide()
	map.show()
	Global.is_simulation_active = true
	Global.is_simulation_paused = false

	for object in get_tree().get_nodes_in_group("poisoned_object"):
		var obj: SmartObject = object
		obj.poison = Global.initial_poison

	for room in room_nodes:
		room.reset_for_simulation(Global.runtime_start_s)

	room_vl_last.clear()
	room_alert_last_eval_s.clear()
	room_alert_active.clear()
	room_budget_last_update_s = Global.runtime_start_s
	room_panel_next_update_s = Global.runtime_start_s

	Global.sim_clock_s = Global.runtime_start_s
	Global.prev_abs_event_s = Global.runtime_start_s
	Global.person_save_file = FileAccess.open(Global.person_output_file_path, FileAccess.WRITE)
	Global.poison_save_file = FileAccess.open(Global.poison_output_file_path, FileAccess.WRITE)
	Global.room_save_file = FileAccess.open(Global.room_output_file_path, FileAccess.WRITE)
	save_timer.start()

func _on_save_object_button_pressed():
	object_file_dialog.show()

func _on_object_file_selected(file: String):
	object_file_dialog.hide()
	save_objects(file)

func _on_start_simulation_button_pressed():
	config_file_dialog.show()

func _on_config_file_selected(file: String):
	config_file_dialog.hide()
	start_simulation(file)

func _on_save_timer_timeout():
	print("Saving pending output")
	for pid in Global.all_persons:
		Global.all_persons[pid].save_events()
	for oid in Global.all_objects:
		Global.all_objects[oid].save_events()
	for room in room_nodes:
		var row = {
			"event": "room_state",
			"time": Global.current_time_s(),
			"room_name": room.display_name(),
			"room_id": room.room_id,
			"ach": room.ach_current,
			"viral_load": room.viral_load,
			"occupant_pids": room.occupant_pid_csv(),
		}
		Global.room_save_file.store_line(JSON.stringify(row))
	Global.person_save_file.flush()
	Global.poison_save_file.flush()
	Global.room_save_file.flush()
	print("Saving pending output complete.")

func _ready() -> void:
	object_file_dialog.file_selected.connect(_on_object_file_selected)
	config_file_dialog.file_selected.connect(_on_config_file_selected)

	save_object_button.pressed.connect(_on_save_object_button_pressed)
	start_simulation_button.pressed.connect(_on_start_simulation_button_pressed)

	var home_dir = OS.get_environment("HOME")
	object_file_dialog.root_subfolder = home_dir
	config_file_dialog.root_subfolder = home_dir

	save_timer.timeout.connect(_on_save_timer_timeout)
	save_timer.wait_time = Global.save_every_s

	for object in get_tree().get_nodes_in_group("smart_object"):
		var oid: String = object.get_path()
		object.object_id = oid
		Global.all_objects[oid] = object

	for room in get_tree().get_nodes_in_group("room"):
		var room_node: Room = room
		if room_node.room_id == "":
			room_node.room_id = room_node.get_path()
		Global.all_rooms[room_node.room_id] = room_node
		room_nodes.append(room_node)

	if room_nodes.size() > 0:
		selected_room_idx = 0
		room_nodes[0].set_selected(true)

	var entrances = Array()
	for entrance in get_tree().get_nodes_in_group("entrance"):
		entrances.append(entrance)
	var num_entrances = len(entrances)
	for i in range(num_entrances):
		for j in range(i+1, num_entrances):
			var link_rid = NavigationServer2D.link_create()
			NavigationServer2D.link_set_owner_id(link_rid, get_instance_id())
			NavigationServer2D.link_set_enter_cost(link_rid, 0.0)
			NavigationServer2D.link_set_travel_cost(link_rid, 1e-6)
			NavigationServer2D.link_set_navigation_layers(link_rid, 1)
			NavigationServer2D.link_set_bidirectional(link_rid, true)

			# Enable the link and set it to the default navigation map.
			NavigationServer2D.link_set_enabled(link_rid, true)
			NavigationServer2D.link_set_map(link_rid, get_viewport().world_2d.get_navigation_map())

			# Move the 2 link positions to their intended global positions.
			NavigationServer2D.link_set_start_position(link_rid, entrances[i].global_position)
			NavigationServer2D.link_set_end_position(link_rid, entrances[j].global_position)

	var user_args = OS.get_cmdline_user_args()
	if len(user_args) == 2 and user_args[0] == "--config":
		start_simulation(user_args[1])


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			_cycle_selected_room(1)
			get_viewport().set_input_as_handled()
			return

		if event.keycode == KEY_E:
			_cycle_selected_room(-1)
			get_viewport().set_input_as_handled()
			return

		if event.keycode == KEY_MINUS or event.keycode == KEY_KP_SUBTRACT:
			_adjust_selected_room_ach(-ROOM_ACH_STEP)
			get_viewport().set_input_as_handled()
			return

		if event.keycode == KEY_EQUAL or event.keycode == KEY_PLUS or event.keycode == KEY_KP_ADD:
			_adjust_selected_room_ach(ROOM_ACH_STEP)
			get_viewport().set_input_as_handled()
			return

		if Global.is_simulation_active and event.keycode == KEY_S:
			_adjust_sim_speed_scale(_sim_speed_step_size())
			get_viewport().set_input_as_handled()
			return

		if Global.is_simulation_active and event.keycode == KEY_D:
			_adjust_sim_speed_scale(-_sim_speed_step_size())
			get_viewport().set_input_as_handled()
			return

	if not Global.is_simulation_active:
		return

	if event.is_action_pressed("pause") and not event.is_echo():
		Global.is_simulation_paused = not Global.is_simulation_paused
		if Global.is_simulation_paused:
			save_timer.stop()
		else:
			save_timer.start()
		get_viewport().set_input_as_handled()

func _cycle_selected_room(direction: int = 1):
	if room_nodes.is_empty():
		return

	if selected_room_idx >= 0 and selected_room_idx < room_nodes.size():
		room_nodes[selected_room_idx].set_selected(false)

	selected_room_idx = (selected_room_idx + direction) % room_nodes.size()
	if selected_room_idx < 0:
		selected_room_idx += room_nodes.size()
	room_nodes[selected_room_idx].set_selected(true)
	_update_room_panel(true)

func _adjust_selected_room_ach(delta: float):
	if room_nodes.is_empty():
		return

	if selected_room_idx < 0 or selected_room_idx >= room_nodes.size():
		selected_room_idx = 0

	room_nodes[selected_room_idx].adjust_ach(delta)
	_update_room_panel(true)

func _sim_speed_bounds() -> Vector2:
	var min_scale: float = float(min(sim_speed_scale_min, sim_speed_scale_max))
	var max_scale: float = float(max(sim_speed_scale_min, sim_speed_scale_max))
	return Vector2(min_scale, max_scale)

func _apply_sim_speed_scale(target_scale: float) -> bool:
	var bounds: Vector2 = _sim_speed_bounds()
	var clamped: float = clampf(target_scale, bounds.x, bounds.y)
	if not is_equal_approx(target_scale, clamped):
		print("Requested sim speed %.3f outside %.3f-%.3f; clamped." % [target_scale, bounds.x, bounds.y])
	var changed := not is_equal_approx(clamped, Global.sim_speed_scale)
	Global.apply_sim_speed_scale(clamped)
	return changed

func _sim_speed_step_size() -> float:
	return max(sim_speed_scale_step, SIM_SPEED_STEP_MIN)

func _adjust_sim_speed_scale(delta: float) -> void:
	if delta == 0.0:
		return
	if _apply_sim_speed_scale(Global.sim_speed_scale + delta):
		print("Simulation speed scale set to %.3f" % Global.sim_speed_scale)

func _short_room_name(room_name: String) -> String:
	var normalized := room_name.replace("\\", "/")
	var parts := normalized.split("/")
	if parts.is_empty():
		return room_name
	return parts[parts.size() - 1]

func _room_vl_color(viral_load: float) -> Color:
	if ROOM_VL_COLOR_POINTS.size() == 0:
		return Color.WHITE

	if viral_load <= float(ROOM_VL_COLOR_POINTS[0]["value"]):
		return ROOM_VL_COLOR_POINTS[0]["color"]

	for idx in range(ROOM_VL_COLOR_POINTS.size() - 1):
		var start_point: Dictionary = ROOM_VL_COLOR_POINTS[idx]
		var end_point: Dictionary = ROOM_VL_COLOR_POINTS[idx + 1]
		var start_value: float = float(start_point["value"])
		var end_value: float = float(end_point["value"])

		if viral_load <= end_value:
			var t := inverse_lerp(start_value, end_value, viral_load)
			return start_point["color"].lerp(end_point["color"], t)

	return ROOM_VL_COLOR_POINTS[ROOM_VL_COLOR_POINTS.size() - 1]["color"]

func _color_tag_text(text_value: String, color: Color) -> String:
	return "[color=%s]%s[/color]" % [color.to_html(false), text_value]

func _current_room_ach_total() -> float:
	var total_ach := 0.0
	for room in room_nodes:
		total_ach += max(0.0, room.ach_current)
	return total_ach

func _update_room_budget() -> void:
	if not Global.can_advance_simulation():
		return

	while Global.sim_clock_s - room_budget_last_update_s >= ROOM_BUDGET_UPDATE_INTERVAL_S:
		var elapsed_hours := ROOM_BUDGET_UPDATE_INTERVAL_S / 3600.0
		var ach_cost := _current_room_ach_total() * Global.room_ach_cost_per_ach_hour * elapsed_hours
		Global.room_ach_budget_remaining = max(0.0, Global.room_ach_budget_remaining - ach_cost)
		room_budget_last_update_s += ROOM_BUDGET_UPDATE_INTERVAL_S

func _room_vl_trend_symbol(room_id: String, current_viral_load: float) -> String:
	if not room_vl_last.has(room_id):
		room_vl_last[room_id] = current_viral_load
		return "-"

	var previous_viral_load: float = float(room_vl_last[room_id])
	room_vl_last[room_id] = current_viral_load

	var delta := current_viral_load - previous_viral_load
	if delta > ROOM_VL_TREND_EPSILON:
		return "↑"
	if delta < -ROOM_VL_TREND_EPSILON:
		return "↓"
	return "="

func _room_selector_marker(idx: int) -> String:
	var active_color := Color("#4caf50")
	var inactive_color := Color("#5f6368")
	if idx == selected_room_idx:
		return _color_tag_text("■", active_color)
	return _color_tag_text("□", inactive_color)

func _room_alert_state(room: Room) -> bool:
	var room_id := room.room_id
	var now_s := Global.current_time_s()
	var should_evaluate := not room_alert_active.has(room_id)
	if not should_evaluate:
		var last_eval := float(room_alert_last_eval_s.get(room_id, -INF))
		if room_alert_check_interval_s <= 0.0 or now_s - last_eval >= room_alert_check_interval_s:
			should_evaluate = true

	if should_evaluate:
		room_alert_active[room_id] = room.viral_load >= room_alert_threshold_vl
		room_alert_last_eval_s[room_id] = now_s

	var is_alerting := bool(room_alert_active.get(room_id, false))
	room.set_alert_indicator(is_alerting)
	return is_alerting

func _room_alert_light(room: Room) -> String:
	var is_alerting := _room_alert_state(room)
	var alert_on_color := Color("#ff4d4f")
	var alert_off_color := Color("#d5d7da")
	var alert_on_symbol  := "▲"
	var alert_off_symbol := "△"
	var chosen_color := alert_on_color if is_alerting else alert_off_color
	var chosen_symbol := alert_on_symbol if is_alerting else alert_off_symbol
	return _color_tag_text(chosen_symbol, chosen_color)

func _format_duration(seconds: float) -> String:
	if seconds <= 0.5:
		return "Now"
	var hrs: int = int(seconds / 3600.0)
	var mins: int = int((seconds - hrs * 3600.0) / 60.0)
	if seconds - (hrs * 3600.0 + mins * 60.0) > 0.0:
		mins += 1
	if hrs > 0:
		return "%dh %02dm" % [hrs, mins]
	return "%dm" % [mins]

func _next_sensor_reading_text() -> String:
	if room_alert_check_interval_s <= 0.0:
		return "Next Sensor Reading: Live"
	if room_nodes.is_empty():
		return "Next Sensor Reading: n/a"

	var now_s: float = Global.current_time_s()
	var next_due: float = INF
	for room in room_nodes:
		var room_id: String = room.room_id
		var last_eval: float = float(room_alert_last_eval_s.get(room_id, now_s))
		var candidate: float = last_eval + room_alert_check_interval_s
		next_due = min(next_due, candidate)

	if next_due == INF:
		return "Next Sensor Reading: n/a"
	var remaining: float = max(0.0, next_due - now_s)
	return "Next Sensor Reading: %s" % _format_duration(remaining)

func _update_room_panel(force_update: bool = false) -> void:
	if room_panel == null or room_panel_text == null:
		return

	room_panel.visible = map.visible
	if not map.visible:
		return

	var now_s := Global.current_time_s()
	if not force_update and room_panel_refresh_interval_s > 0.0 and now_s < room_panel_next_update_s:
		return
	room_panel_next_update_s = now_s + room_panel_refresh_interval_s

	if room_nodes.is_empty():
		room_panel_text.text = "Rooms\n(no rooms found)"
		return

	var lines: Array[String] = []
	lines.append("[center][b]Rooms[/b] (R next, E prev, +/- ACH, S faster, D slower)[/center]")
	lines.append("")
	lines.append("[table=6]" )
	lines.append("[cell][/cell][cell][center]Room[/center][/cell][cell][center]Alert[/center][/cell][cell][center]ACH[/center][/cell][cell][center]VL[/center][/cell][cell][center]Trend[/center][/cell]")

	for idx in range(room_nodes.size()):
		var room := room_nodes[idx]
		var row_color := _room_vl_color(room.viral_load)
		var selector := _room_selector_marker(idx)
		var room_name_text := "  " + _color_tag_text(_short_room_name(room.room_id), row_color)
		var trend_symbol := _room_vl_trend_symbol(room.room_id, room.viral_load)
		var trend_text := _color_tag_text(trend_symbol, row_color)
		var vl_text := _color_tag_text("%.1f" % room.viral_load, row_color)
		var alert_light := _room_alert_light(room)
		var cell_values := [selector, room_name_text, alert_light, "%.1f" % room.ach_current, vl_text, trend_text]
		if idx == selected_room_idx:
			var prefix := "[b]"
			var suffix := "[/b]"
			for c in range(cell_values.size()):
				cell_values[c] = "%s%s%s" % [prefix, cell_values[c], suffix]
		lines.append("[cell]%s[/cell][cell]%s[/cell][cell]%s[/cell][cell]%s[/cell][cell]%s[/cell][cell]%s[/cell]" % cell_values)

	lines.append("[/table]")
	lines.append("")
	lines.append("[b]Budget:[/b] $%.2f / $%.2f" % [Global.room_ach_budget_remaining, Global.room_ach_budget_start])
	lines.append("Rate: $%.2f per ACH-hour" % [Global.room_ach_cost_per_ach_hour])
	lines.append("[b]Sim Speed:[/b] x%.2f (S faster, D slower)" % Global.sim_speed_scale)
	lines.append(_next_sensor_reading_text())

	room_panel_text.text = "\n".join(lines)


func _process(_delta: float) -> void:
	if Input.is_action_pressed("camera_right"):
		camera_2d.offset.x += 32
	if Input.is_action_pressed("camera_left"):
		camera_2d.offset.x -= 32
	if Input.is_action_pressed("camera_down"):
		camera_2d.offset.y += 32
	if Input.is_action_pressed("camera_up"):
		camera_2d.offset.y -= 32
	if Input.is_action_pressed("zoom_in"):
		camera_2d.zoom.x *= 1.05
		camera_2d.zoom.y *= 1.05
	if Input.is_action_pressed("zoom_out"):
		camera_2d.zoom.x *= 0.95
		camera_2d.zoom.y *= 0.95
	#if Input.is_action_pressed("pause"):
		#get_tree().paused = true
	#if Input.is_action_pressed("unpause"):
		#get_tree().paused = false

	var c_time = Global.current_time_s()
	var c_time_h = int(c_time / 3600)
	var c_time_m = int((c_time - c_time_h * 3600) / 60)
	var fps = Engine.get_frames_per_second()
	var pause_text := " [PAUSED]" if Global.is_simulation_paused else ""
	var room_text := ""
	if selected_room_idx >= 0 and selected_room_idx < room_nodes.size():
		var selected_room = room_nodes[selected_room_idx]
		room_text = "   Room: %s ACH %.1f VL %.2f" % [_short_room_name(selected_room.room_id), selected_room.ach_current, selected_room.viral_load]
	var speed_text := "   Speed x%.2f" % Global.sim_speed_scale

	current_time_label.text = "Time: %02.0f:%02.0f%s   FPS: %d%s%s" % [c_time_h, c_time_m, pause_text, fps, speed_text, room_text]
	_update_room_panel()

	if Global.current_time_s() > Global.runtime_end_s:
		Global.is_simulation_active = false
		Global.is_simulation_paused = false
		save_timer.stop()
		_on_save_timer_timeout()
		Global.person_save_file.close()
		Global.poison_save_file.close()
		Global.room_save_file.close()
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
		get_tree().quit()

func _physics_process(_delta: float) -> void:
	if Global.can_advance_simulation() and Global.sim_clock_s > 0.0:
		Global.sim_clock_s += Global.seconds_per_physics_tick
		_update_room_budget()

		if Global.sim_clock_s - Global.prev_abs_event_s > Global.abs_tick_duration_s:
			for pid in Global.all_persons:
				Global.all_persons[pid].do_absorption()
			Global.prev_abs_event_s = Global.sim_clock_s
