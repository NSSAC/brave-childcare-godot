extends Node

@onready var object_file_dialog: FileDialog = %ObjectFileDialog
@onready var config_file_dialog: FileDialog = %ConfigFileDialog

@onready var save_object_button: Button = %SaveObjectButton
@onready var start_simulation_button: Button = %StartSimulationButton
@onready var start_simulation_default_button: Button = %StartSimulationDefaultButton
@onready var player_name_input: LineEdit = %PlayerNameInput

@onready var title_screen: CanvasLayer = %TitleScreen
@onready var map: Node2D = %Map
@onready var camera_2d: Camera2D = %Camera2D
@onready var current_time_label: Label = %CurrentTimeLabel
@onready var end_simulation_button: Button = %EndSimulationButton
@onready var last_run_summary_label: Label = %LastRunSummaryLabel
@onready var room_panel: PanelContainer = %RoomPanel
@onready var room_panel_text: RichTextLabel = %RoomPanelText
@onready var room_panel_margin: MarginContainer = $Map/CanvasLayer/RoomPanel/MarginContainer

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

@export var default_config_path: String = "res://Sample Inputs/config_childcare.json"
@export var room_alert_threshold_vl: float = 400.0
@export var room_alert_check_interval_s: float = 45.0 * 60.0
@export var room_panel_refresh_interval_s: float = 0.5
@export var sim_speed_scale_step: float = 0.2
@export var sim_speed_scale_min: float = 0.1
@export var sim_speed_scale_max: float = 3.0
@export var initial_camera_padding: Vector2 = Vector2(220.0, 180.0)
@export var initial_camera_zoom_min: float = 0.12
@export var initial_camera_zoom_max: float = 1.0
@export var room_panel_width_fraction: float = 0.28
@export var room_panel_height_fraction: float = 0.78
@export var room_panel_max_width_fraction: float = 0.25
@export var room_panel_min_width: float = 320.0
@export var room_panel_max_width: float = 920.0
@export var room_panel_min_height: float = 280.0
@export var room_panel_max_height: float = 980.0
@export var room_panel_screen_margin: float = 20.0
@export var room_panel_width_scale_start_px: float = 800.0
@export var room_panel_width_scale_end_px: float = 520.0
@export var room_panel_font_size_min: int = 20
@export var room_panel_font_size_max: int = 42
@export var room_panel_line_separation_min: int = 4
@export var room_panel_line_separation_max: int = 8
@export var room_panel_margin_min: int = 12
@export var room_panel_margin_max: int = 24

var room_nodes: Array = []
var selected_room_idx: int = -1
var room_vl_last: Dictionary = {}
var room_alert_last_eval_s: Dictionary = {}
var room_alert_active: Dictionary = {}
var room_alert_trigger_count_total: int = 0
var room_alert_trigger_count_by_room: Dictionary = {}
var room_cost_last_update_s: float = 0.0
var room_panel_next_update_s: float = 0.0
var last_viewport_size: Vector2 = Vector2.ZERO
var health_mode_active: bool = false
var health_mode_baseline_ach: float = 3.0
var health_mode_max_ach: float = 6.0
var health_mode_min_ach: float = 0.0
var active_config_path: String = ""
var active_config_for_archive: Dictionary = {}

const ROOM_ACH_STEP: float = 1.0
const ROOM_VL_TREND_EPSILON: float = 0.01
const ROOM_COST_UPDATE_INTERVAL_S: float = 60.0
const ROOM_VL_COLOR_POINTS := [
	{"value": 0.0, "color": Color("#44c96b")},
	{"value": 250.0, "color": Color("#ff9f1c")},
	{"value": 400.0, "color": Color("#e63946")},
	{"value": 800.0, "color": Color("#cf4dff")}
]
const SIM_SPEED_STEP_MIN: float = 0.001

func _fit_camera_to_map_contents() -> void:
	if camera_2d == null or map == null:
		return

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	var found_any := false

	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		var room_pos: Vector2 = room.global_position
		min_pos.x = min(min_pos.x, room_pos.x)
		min_pos.y = min(min_pos.y, room_pos.y)
		max_pos.x = max(max_pos.x, room_pos.x)
		max_pos.y = max(max_pos.y, room_pos.y)
		found_any = true

	for oid in Global.all_objects:
		var obj = Global.all_objects[oid]
		if not is_instance_valid(obj):
			continue
		var obj_pos: Vector2 = obj.global_position
		min_pos.x = min(min_pos.x, obj_pos.x)
		min_pos.y = min(min_pos.y, obj_pos.y)
		max_pos.x = max(max_pos.x, obj_pos.x)
		max_pos.y = max(max_pos.y, obj_pos.y)
		found_any = true

	if not found_any:
		return

	min_pos -= initial_camera_padding
	max_pos += initial_camera_padding

	var content_size := (max_pos - min_pos).abs()
	content_size.x = max(content_size.x, 1.0)
	content_size.y = max(content_size.y, 1.0)

	var center := (min_pos + max_pos) * 0.5
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var zoom_x := viewport_size.x / content_size.x
	var zoom_y := viewport_size.y / content_size.y
	var target_zoom := clampf(min(zoom_x, zoom_y), initial_camera_zoom_min, initial_camera_zoom_max)

	camera_2d.position = center
	camera_2d.offset = Vector2.ZERO
	camera_2d.zoom = Vector2(target_zoom, target_zoom)

func _update_room_panel_layout() -> void:
	if room_panel == null or room_panel_text == null or room_panel_margin == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	last_viewport_size = viewport_size

	var panel_width := clampf(viewport_size.x * room_panel_width_fraction, room_panel_min_width, room_panel_max_width)
	var panel_height := clampf(viewport_size.y * room_panel_height_fraction, room_panel_min_height, room_panel_max_height)
	panel_width = min(panel_width, viewport_size.x * room_panel_max_width_fraction)
	panel_width = min(panel_width, max(160.0, viewport_size.x - room_panel_screen_margin * 2.0))
	panel_height = min(panel_height, max(120.0, viewport_size.y - room_panel_screen_margin * 2.0))

	room_panel.anchor_left = 1.0
	room_panel.anchor_right = 1.0
	room_panel.anchor_top = 0.5
	room_panel.anchor_bottom = 0.5
	room_panel.offset_left = -room_panel_screen_margin - panel_width
	room_panel.offset_right = -room_panel_screen_margin
	room_panel.offset_top = -panel_height * 0.5
	room_panel.offset_bottom = panel_height * 0.5

	var height_scale := clampf(inverse_lerp(720.0, 1600.0, viewport_size.y), 0.0, 1.0)
	var width_scale_start: float = minf(room_panel_width_scale_start_px, room_panel_width_scale_end_px)
	var width_scale_end: float = maxf(room_panel_width_scale_start_px, room_panel_width_scale_end_px)
	var width_scale := clampf(inverse_lerp(width_scale_start, width_scale_end, panel_width), 0.0, 1.0)
	var ui_scale: float = minf(height_scale, width_scale)
	var target_font_size := int(round(lerpf(room_panel_font_size_min, room_panel_font_size_max, ui_scale)))
	var line_separation := int(round(lerpf(room_panel_line_separation_min, room_panel_line_separation_max, ui_scale)))
	var margin_size := int(round(lerpf(room_panel_margin_min, room_panel_margin_max, ui_scale)))

	room_panel_text.add_theme_font_size_override("normal_font_size", target_font_size)
	room_panel_text.add_theme_font_size_override("bold_font_size", target_font_size)
	room_panel_text.add_theme_constant_override("line_separation", line_separation)
	room_panel_text.scroll_active = viewport_size.y < 900.0 or viewport_size.x < 1500.0

	room_panel_margin.add_theme_constant_override("margin_left", margin_size)
	room_panel_margin.add_theme_constant_override("margin_top", margin_size)
	room_panel_margin.add_theme_constant_override("margin_right", margin_size)
	room_panel_margin.add_theme_constant_override("margin_bottom", margin_size)

func _derive_room_output_path(sim_output_file: String) -> String:
	if sim_output_file.ends_with(".json"):
		return sim_output_file.trim_suffix(".json") + "_rooms.json"
	return sim_output_file + "_rooms.json"

func _derive_poison_output_path(person_output_file: String) -> String:
	if person_output_file.ends_with(".json"):
		return person_output_file.trim_suffix(".json") + "_poison.json"
	return person_output_file + "_poison.json"

func _derive_exposure_output_path(person_output_file: String) -> String:
	if person_output_file.ends_with(".json"):
		return person_output_file.trim_suffix(".json") + "_exposure.json"
	return person_output_file + "_exposure.json"

func _derive_stats_output_path(person_output_file: String) -> String:
	if person_output_file.ends_with(".json"):
		return person_output_file.trim_suffix(".json") + "_stats.json"
	return person_output_file + "_stats.json"

func _format_run_id(run_number: int) -> String:
	return "%04d" % max(run_number, 0)

func _strip_run_id_suffix(output_path: String) -> String:
	var regex := RegEx.new()
	regex.compile("_id-[0-9]+\\.json$")
	var match := regex.search(output_path)
	if match == null:
		return output_path
	var start_idx: int = int(match.get_start())
	return output_path.substr(0, start_idx) + ".json"

func _with_run_id_suffix(output_path: String, run_id: String) -> String:
	output_path = _strip_run_id_suffix(output_path)
	var suffix := "_id-%s" % run_id
	if output_path.ends_with(".json"):
		return output_path.trim_suffix(".json") + suffix + ".json"
	return output_path + suffix

func _next_run_number_from_dir(dir_path: String) -> int:
	var dir := DirAccess.open(dir_path)
	if dir == null:
		return 0

	var regex := RegEx.new()
	regex.compile("_id-([0-9]+)\\.json$")

	var max_run_number := -1
	dir.list_dir_begin()
	while true:
		var file_name := dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue

		var match := regex.search(file_name)
		if match == null:
			continue

		var run_str: String = match.get_string(1)
		if not run_str.is_valid_int():
			continue

		var parsed_run := int(run_str)
		if parsed_run > max_run_number:
			max_run_number = parsed_run
	dir.list_dir_end()

	return max_run_number + 1

func _resolve_run_number(config_run_number: int, output_dirs: Array[String]) -> int:
	var detected_next_run := 0
	for output_dir in output_dirs:
		detected_next_run = max(detected_next_run, _next_run_number_from_dir(output_dir))
	return max(config_run_number, detected_next_run)

func _resolve_stats_output_path_from_config(config_path: String) -> String:
	if config_path == "":
		return ""
	if not FileAccess.file_exists(config_path):
		return ""

	var config_file := FileAccess.open(config_path, FileAccess.READ)
	if config_file == null:
		return ""

	var config_data = JSON.parse_string(config_file.get_as_text())
	if not config_data is Dictionary:
		return ""

	var person_output_file: String = str(config_data.get("person_output_file", config_data.get("output_file", "output_people.json")))
	var stats_output_file: String = str(config_data.get("stats_output_file", ""))
	if stats_output_file == "":
		stats_output_file = _derive_stats_output_path(person_output_file)
	if not stats_output_file.is_absolute_path():
		stats_output_file = config_path.get_base_dir().path_join(stats_output_file)
	return stats_output_file

func _read_last_run_summary_row(stats_file_path: String) -> Dictionary:
	if stats_file_path == "":
		return {}
	if not FileAccess.file_exists(stats_file_path):
		return {}

	var stats_file := FileAccess.open(stats_file_path, FileAccess.READ)
	if stats_file == null:
		return {}

	var lines: PackedStringArray = stats_file.get_as_text().split("\n", false)
	for idx in range(lines.size() - 1, -1, -1):
		var line: String = lines[idx].strip_edges()
		if line == "":
			continue
		var parsed = JSON.parse_string(line)
		if parsed is Dictionary and str(parsed.get("event", "")) == "run_summary":
			return parsed
	return {}

func _refresh_last_run_summary(stats_file_path: String = "") -> void:
	if last_run_summary_label == null:
		return

	var effective_stats_file_path := stats_file_path
	if effective_stats_file_path == "":
		effective_stats_file_path = _resolve_stats_output_path_from_config(default_config_path)

	var row: Dictionary = _read_last_run_summary_row(effective_stats_file_path)
	if row.is_empty():
		last_run_summary_label.text = "Last Run: none yet"
		return

	var run_id: String = str(row.get("run_id", "n/a"))
	var player_name: String = str(row.get("player_name", ""))
	if player_name == "":
		player_name = "Anonymous"
	var alert_count: int = int(row.get("alert_trigger_count", 0))
	var total_cost: float = float(row.get("ach_total_cost", 0.0))
	var exposure_mean: float = float(row.get("exposure_mean_cumulative", 0.0))
	var exposure_max: float = float(row.get("exposure_max_cumulative", 0.0))
	var end_reason: String = str(row.get("end_reason", "n/a"))

	last_run_summary_label.text = "Last Run %s | %s | Alerts %d | Cost $%.2f | Exposure Avg %.2f Max %.2f | End %s" % [
		run_id,
		player_name,
		alert_count,
		total_cost,
		exposure_mean,
		exposure_max,
		end_reason
	]

func _safe_close_file(file_handle: FileAccess) -> void:
	if file_handle != null:
		file_handle.close()

func _archive_run_config() -> void:
	if active_config_path == "":
		return

	var archive_config: Dictionary = active_config_for_archive.duplicate(true)
	archive_config["run_number"] = Global.run_number
	archive_config["run_id"] = Global.run_id
	archive_config["run_suffix"] = "_id-%s" % Global.run_id

	var archive_file_name: String = "archived_config_id-%s.json" % Global.run_id
	var archive_file_path: String = active_config_path.get_base_dir().path_join(archive_file_name)
	var archive_file: FileAccess = FileAccess.open(archive_file_path, FileAccess.WRITE)
	if archive_file == null:
		print("Failed to archive config file: ", archive_file_path)
		return

	archive_file.store_string(JSON.stringify(archive_config, "\t"))
	archive_file.store_string("\n")
	archive_file.close()

func _clear_simulation_persons() -> void:
	for pid in Global.all_persons:
		var person = Global.all_persons[pid]
		if is_instance_valid(person):
			person.queue_free()
	Global.all_persons.clear()

func _configure_rooms_health_bounds() -> void:
	for room in room_nodes:
		if is_instance_valid(room) and room.has_method("configure_ach_bounds"):
			room.configure_ach_bounds(health_mode_min_ach, health_mode_max_ach, health_mode_baseline_ach)

func _set_health_mode(active: bool) -> void:
	if health_mode_active == active:
		return

	health_mode_active = active
	var current_time_s: float = Global.current_time_s()
	for room in room_nodes:
		if is_instance_valid(room) and room.has_method("set_health_mode_enabled"):
			room.set_health_mode_enabled(health_mode_active, current_time_s)

	if health_mode_active:
		_apply_health_mode_ach_overrides()
	_update_room_panel(true)

func _apply_health_mode_ach_overrides() -> void:
	if not health_mode_active:
		return

	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		if room.has_method("apply_health_mode_alert"):
			var alert_active_now: bool = room.viral_load >= room_alert_threshold_vl
			room.apply_health_mode_alert(alert_active_now)

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

		var person = scene_to_spawn.instantiate()
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
		var person = Global.all_persons[pid]
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

	var config_file: FileAccess = FileAccess.open(file, FileAccess.READ)
	var parsed_config = JSON.parse_string(config_file.get_as_text())
	if not parsed_config is Dictionary:
		print("Config file must be a JSON object: ", file)
		return
	var config_data: Dictionary = parsed_config
	active_config_path = file
	active_config_for_archive = config_data.duplicate(true)

	var person_file: String = config_data["person_file"]
	var schedule_file: String = config_data["schedule_file"]
	var person_output_file: String = str(config_data.get("person_output_file", config_data.get("output_file", "output_people.json")))
	var poison_output_file: String = str(config_data.get("poison_output_file", ""))
	var room_output_file: String = str(config_data.get("room_output_file", ""))
	var exposure_output_file: String = str(config_data.get("exposure_output_file", ""))
	var stats_output_file: String = str(config_data.get("stats_output_file", ""))
	var room_ach_file: String = str(config_data.get("room_ach_file", ""))
	var config_run_number: int = maxi(int(config_data.get("run_number", 0)), 0)
	var config_health_baseline: float = float(config_data.get("health_mode_baseline_ach", config_data.get("baseline_ach", 3.0)))
	var config_health_max: float = float(config_data.get("health_mode_max_ach", config_data.get("max_ach", 6.0)))
	var config_health_min: float = float(config_data.get("health_mode_min_ach", config_data.get("minimum_ach", 0.0)))
	health_mode_min_ach = minf(config_health_min, config_health_max)
	health_mode_max_ach = maxf(config_health_min, config_health_max)
	health_mode_baseline_ach = clampf(config_health_baseline, health_mode_min_ach, health_mode_max_ach)

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
	if exposure_output_file == "":
		exposure_output_file = _derive_exposure_output_path(person_output_file)
	if not exposure_output_file.is_absolute_path():
		exposure_output_file = file.get_base_dir().path_join(exposure_output_file)
	if stats_output_file == "":
		stats_output_file = _derive_stats_output_path(person_output_file)
	if not stats_output_file.is_absolute_path():
		stats_output_file = file.get_base_dir().path_join(stats_output_file)

	var output_dirs: Array[String] = [
		person_output_file.get_base_dir(),
		poison_output_file.get_base_dir(),
		room_output_file.get_base_dir(),
		exposure_output_file.get_base_dir()
	]
	Global.run_number = _resolve_run_number(config_run_number, output_dirs)
	Global.run_id = _format_run_id(Global.run_number)

	person_output_file = _with_run_id_suffix(person_output_file, Global.run_id)
	poison_output_file = _with_run_id_suffix(poison_output_file, Global.run_id)
	room_output_file = _with_run_id_suffix(room_output_file, Global.run_id)
	exposure_output_file = _with_run_id_suffix(exposure_output_file, Global.run_id)
	if room_ach_file != "" and not room_ach_file.is_absolute_path():
		room_ach_file = file.get_base_dir().path_join(room_ach_file)

	_clear_simulation_persons()

	create_persons(person_file)
	load_schedule(schedule_file)
	Global.person_output_file_path = person_output_file
	Global.poison_output_file_path = poison_output_file
	Global.room_output_file_path = room_output_file
	Global.exposure_output_file_path = exposure_output_file
	Global.stats_output_file_path = stats_output_file

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
	Global.room_ach_total_cost = float(config_data.get("room_ach_total_cost_start", 0.0))
	Global.room_ach_cost_per_ach_hour = float(config_data.get("room_ach_cost_per_ach_hour", 5.0))

	if room_ach_file != "":
		load_room_ach_schedule(room_ach_file)

	_fit_camera_to_map_contents()

func load_room_ach_schedule(file: String):
	print("Loading room ACH schedule from file: ", file)
	var schedule_file = FileAccess.open(file, FileAccess.READ)
	var schedule_data = JSON.parse_string(schedule_file.get_as_text())

	if not schedule_data is Array:
		print("Room ACH schedule must be an array of rows")
		return

	for rid in Global.all_rooms:
		Global.all_rooms[rid].set_ach_schedule([])

	var room_ids_by_alias: Dictionary = {}
	for rid in Global.all_rooms:
		var room = Global.all_rooms[rid]
		room_ids_by_alias[room.room_id] = room.room_id
		room_ids_by_alias[room.display_name()] = room.room_id

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
		var resolved_room_id: String = str(room_ids_by_alias.get(room_id, ""))
		if resolved_room_id != "" and Global.all_rooms.has(resolved_room_id):
			Global.all_rooms[resolved_room_id].set_ach_schedule(rows_by_room[room_id])
		else:
			print("Room ACH schedule references unknown room_id: ", room_id)

	print("Loaded ACH rows for ", rows_by_room.size(), " rooms")

func start_simulation(file: String):
	Global.player_name = player_name_input.text.strip_edges()
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
	_configure_rooms_health_bounds()
	_set_health_mode(false)

	room_vl_last.clear()
	room_alert_last_eval_s.clear()
	room_alert_active.clear()
	room_alert_trigger_count_total = 0
	room_alert_trigger_count_by_room.clear()
	room_cost_last_update_s = Global.runtime_start_s
	room_panel_next_update_s = Global.runtime_start_s

	Global.sim_clock_s = Global.runtime_start_s
	Global.prev_abs_event_s = Global.runtime_start_s
	Global.person_save_file = FileAccess.open(Global.person_output_file_path, FileAccess.WRITE)
	Global.poison_save_file = FileAccess.open(Global.poison_output_file_path, FileAccess.WRITE)
	Global.room_save_file = FileAccess.open(Global.room_output_file_path, FileAccess.WRITE)
	Global.exposure_save_file = FileAccess.open(Global.exposure_output_file_path, FileAccess.WRITE)
	if FileAccess.file_exists(Global.stats_output_file_path):
		Global.stats_save_file = FileAccess.open(Global.stats_output_file_path, FileAccess.READ_WRITE)
		if Global.stats_save_file != null:
			Global.stats_save_file.seek_end()
	else:
		Global.stats_save_file = FileAccess.open(Global.stats_output_file_path, FileAccess.WRITE)
	save_timer.wait_time = Global.save_every_s
	var session_header_json: String = JSON.stringify({
		"event": "session_start",
		"player_name": Global.player_name,
		"run_number": Global.run_number,
		"run_id": Global.run_id,
		"timestamp": Time.get_datetime_string_from_system()
	})
	Global.person_save_file.store_line(session_header_json)
	Global.poison_save_file.store_line(session_header_json)
	Global.room_save_file.store_line(session_header_json)
	Global.exposure_save_file.store_line(session_header_json)
	save_timer.start()
	_update_room_panel(true)

func _end_simulation(reason: String = "manual") -> void:
	if not Global.is_simulation_active:
		return

	Global.is_simulation_active = false
	Global.is_simulation_paused = false
	save_timer.stop()
	_on_save_timer_timeout()
	_write_panel_stats_snapshot(reason)
	_archive_run_config()

	_safe_close_file(Global.person_save_file)
	_safe_close_file(Global.poison_save_file)
	_safe_close_file(Global.room_save_file)
	_safe_close_file(Global.exposure_save_file)
	_safe_close_file(Global.stats_save_file)

	title_screen.show()
	map.hide()
	_set_health_mode(false)
	_refresh_last_run_summary(Global.stats_output_file_path)
	_update_room_panel(true)
	current_time_label.text = "Current Time: 0.0"

func _on_save_object_button_pressed():
	object_file_dialog.show()

func _on_object_file_selected(file: String):
	object_file_dialog.hide()
	save_objects(file)

func _on_start_simulation_default_button_pressed():
	start_simulation(default_config_path)

func _on_start_simulation_button_pressed():
	config_file_dialog.show()

func _on_config_file_selected(file: String):
	config_file_dialog.hide()
	start_simulation(file)

func _on_player_name_input_changed(new_text: String):
	Global.player_name = new_text.strip_edges()

func _on_end_simulation_button_pressed():
	_end_simulation("manual")

func _exposure_stats() -> Dictionary:
	if Global.all_persons.is_empty():
		return {
			"count": 0,
			"mean": 0.0,
			"max": 0.0,
			"max_pid": ""
		}

	var total: float = 0.0
	var max_value: float = -INF
	var max_pid: String = ""
	var count: int = 0

	for pid in Global.all_persons:
		var person = Global.all_persons[pid]
		var value: float = person.cumulative_viral_exposure
		total += value
		count += 1
		if value > max_value:
			max_value = value
			max_pid = person.pid

	if count == 0:
		max_value = 0.0

	return {
		"count": count,
		"mean": total / float(max(count, 1)),
		"max": max_value,
		"max_pid": max_pid
	}

func _write_panel_stats_snapshot(reason: String = "schedule_complete") -> void:
	if Global.stats_save_file == null:
		return

	var exposure_stats: Dictionary = _exposure_stats()
	var row := {
		"event": "run_summary",
		"time": Global.current_time_s(),
		"timestamp": Time.get_datetime_string_from_system(),
		"player_name": Global.player_name,
		"run_number": Global.run_number,
		"run_id": Global.run_id,
		"end_reason": reason,
		"sim_speed_scale": Global.sim_speed_scale,
		"alert_trigger_count": room_alert_trigger_count_total,
		"ach_total_cost": Global.room_ach_total_cost,
		"ach_cost_rate_per_ach_hour": Global.room_ach_cost_per_ach_hour,
		"exposure_mean_cumulative": float(exposure_stats["mean"]),
		"exposure_max_cumulative": float(exposure_stats["max"]),
		"exposure_max_pid": str(exposure_stats["max_pid"]),
		"next_sensor_reading": _next_sensor_reading_text(),
		"room_count": room_nodes.size(),
		"total_ach": _current_room_ach_total()
	}
	Global.stats_save_file.store_line(JSON.stringify(row))

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
			"ach_total_cost": Global.room_ach_total_cost,
			"occupant_pids": room.occupant_pid_csv(),
		}
		Global.room_save_file.store_line(JSON.stringify(row))
	for pid in Global.all_persons:
		var person = Global.all_persons[pid]
		var exposure_row = {
			"event": "person_exposure",
			"time": Global.current_time_s(),
			"pid": person.pid,
			"cumulative_viral_exposure": person.cumulative_viral_exposure,
			"sample_count": person.exposure_sample_count,
		}
		Global.exposure_save_file.store_line(JSON.stringify(exposure_row))
	Global.person_save_file.flush()
	Global.poison_save_file.flush()
	Global.room_save_file.flush()
	Global.exposure_save_file.flush()
	if Global.stats_save_file != null:
		Global.stats_save_file.flush()
	print("Saving pending output complete.")

func _ready() -> void:
	object_file_dialog.file_selected.connect(_on_object_file_selected)
	config_file_dialog.file_selected.connect(_on_config_file_selected)

	save_object_button.pressed.connect(_on_save_object_button_pressed)
	start_simulation_button.pressed.connect(_on_start_simulation_button_pressed)
	start_simulation_default_button.pressed.connect(_on_start_simulation_default_button_pressed)
	end_simulation_button.pressed.connect(_on_end_simulation_button_pressed)
	player_name_input.text_changed.connect(_on_player_name_input_changed)
	_refresh_last_run_summary()

	var home_dir = OS.get_environment("HOME")
	object_file_dialog.root_subfolder = home_dir
	config_file_dialog.root_subfolder = home_dir

	save_timer.timeout.connect(_on_save_timer_timeout)
	save_timer.wait_time = Global.save_every_s
	get_viewport().size_changed.connect(_update_room_panel_layout)

	for object in get_tree().get_nodes_in_group("smart_object"):
		var oid: String = object.get_path()
		object.object_id = oid
		Global.all_objects[oid] = object

	for room in get_tree().get_nodes_in_group("room"):
		var room_node = room
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

	call_deferred("_fit_camera_to_map_contents")
	call_deferred("_update_room_panel_layout")

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

		if Global.is_simulation_active and event.keycode == KEY_H:
			_set_health_mode(not health_mode_active)
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

func _room_ach_mode_marker(room) -> String:
	if health_mode_active:
		return "🄷"
	if room.has_method("ach_mode_marker"):
		return room.ach_mode_marker()
	return "🅂" if room.has_ach_schedule() else "🄼"

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

func _update_room_cost() -> void:
	if not Global.can_advance_simulation():
		return

	while Global.sim_clock_s - room_cost_last_update_s >= ROOM_COST_UPDATE_INTERVAL_S:
		var elapsed_hours := ROOM_COST_UPDATE_INTERVAL_S / 3600.0
		var ach_cost := _current_room_ach_total() * Global.room_ach_cost_per_ach_hour * elapsed_hours
		Global.room_ach_total_cost += ach_cost
		room_cost_last_update_s += ROOM_COST_UPDATE_INTERVAL_S

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

func _room_alert_state(room) -> bool:
	var room_id: String = room.room_id
	var now_s := Global.current_time_s()
	var should_evaluate := not room_alert_active.has(room_id)
	var previous_state: bool = bool(room_alert_active.get(room_id, false))
	if not should_evaluate:
		var last_eval := float(room_alert_last_eval_s.get(room_id, -INF))
		if room_alert_check_interval_s <= 0.0 or now_s - last_eval >= room_alert_check_interval_s:
			should_evaluate = true

	if should_evaluate:
		var new_state: bool = room.viral_load >= room_alert_threshold_vl
		room_alert_active[room_id] = new_state
		if new_state and not previous_state:
			room_alert_trigger_count_total += 1
			var per_room_count: int = int(room_alert_trigger_count_by_room.get(room_id, 0))
			room_alert_trigger_count_by_room[room_id] = per_room_count + 1
		room_alert_last_eval_s[room_id] = now_s

	var is_alerting := bool(room_alert_active.get(room_id, false))
	room.set_alert_indicator(is_alerting)
	return is_alerting

func _room_alert_light(room) -> String:
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

func _exposure_summary_text() -> String:
	var exposure_stats: Dictionary = _exposure_stats()
	var count: int = int(exposure_stats["count"])
	if count == 0:
		return "Exposure: n/a"

	return "[b]Exposure:[/b] Avg Cum %.2f | Max %.2f (PID %s)" % [
		float(exposure_stats["mean"]),
		float(exposure_stats["max"]),
		str(exposure_stats["max_pid"])
	]

func _ach_control_mode_text() -> String:
	if health_mode_active:
		return "[b]ACH Control:[/b] Health Mode (🄷 active, H toggle)"
	return "[b]ACH Control:[/b] Schedule/Manual (🅂/🄼, H toggle)"

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
	lines.append("[center][b]Rooms[/b] (R next, E prev, +/- ACH, H health mode, S faster, D slower)[/center]")
	lines.append("")
	lines.append("")
	lines.append("[table=6]" )
	lines.append("[cell] [/cell][cell][center] Room [/center][/cell][cell][center] Alert [/center][/cell][cell][center] ACH [/center][/cell][cell][center] VL [/center][/cell][cell][center] Trend [/center][/cell]")

	for idx in range(room_nodes.size()):
		var room = room_nodes[idx]
		var row_color := _room_vl_color(room.viral_load)
		var selector := _room_selector_marker(idx)
		var room_name_text := "  " + _color_tag_text(_short_room_name(room.room_id), row_color)
		var trend_symbol := _room_vl_trend_symbol(room.room_id, room.viral_load)
		var trend_text := _color_tag_text(trend_symbol, row_color)
		var vl_text := _color_tag_text("%.1f" % room.viral_load, row_color)
		var alert_light := _room_alert_light(room)
		var ach_cell := _room_ach_mode_marker(room) + " %.1f" % room.ach_current
		var cell_values := [selector, room_name_text, alert_light, ach_cell, vl_text, trend_text]
		if idx == selected_room_idx:
			var prefix := "[b]"
			var suffix := "[/b]"
			for c in range(cell_values.size()):
				cell_values[c] = "%s%s%s" % [prefix, cell_values[c], suffix]
		lines.append("[cell] %s [/cell][cell] %s [/cell][cell] %s [/cell][cell] %s [/cell][cell] %s [/cell][cell] %s [/cell]" % cell_values)

	lines.append("[/table]")
	lines.append("")
	lines.append("")
	lines.append("[b]Total Cost:[/b] $%.2f" % [Global.room_ach_total_cost])
	lines.append("Rate: $%.2f per ACH-hour" % [Global.room_ach_cost_per_ach_hour])
	lines.append("")
	lines.append("[b]Sim Speed:[/b] x%.2f (S faster, D slower)" % Global.sim_speed_scale)
	lines.append(_next_sensor_reading_text())
	lines.append("[b]Alert Triggers:[/b] %d" % room_alert_trigger_count_total)
	lines.append("")
	lines.append(_exposure_summary_text())
	lines.append("")
	lines.append(_ach_control_mode_text())

	room_panel_text.text = "\n".join(lines)


func _process(_delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size != last_viewport_size:
		_update_room_panel_layout()

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
		_end_simulation("schedule_complete")

func _physics_process(_delta: float) -> void:
	if Global.can_advance_simulation() and Global.sim_clock_s > 0.0:
		Global.sim_clock_s += Global.seconds_per_physics_tick
		_apply_health_mode_ach_overrides()
		_update_room_cost()

		if Global.sim_clock_s - Global.prev_abs_event_s > Global.abs_tick_duration_s:
			for pid in Global.all_persons:
				Global.all_persons[pid].do_absorption()
			Global.prev_abs_event_s = Global.sim_clock_s
