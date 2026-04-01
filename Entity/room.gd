class_name Room extends Area2D

@export var room_id: String = ""
@export var ach_default: float = 3.0
@export var ach_current: float = 3.0
@export var viral_load: float = 0.0
@export var infected_emission_per_s: float = 1.0
@export var non_vent_decay_per_s: float = 0.0
@export var label_offset: Vector2 = Vector2(-120.0, -120.0)
@export var label_size: Vector2 = Vector2(340.0, 100.0)
@export var label_selected_background: Color = Color(0.0, 0.0, 0.0, 0.95)
@export var label_selected_font_scale: float = 1.1
@export var alert_overlay_color: Color = Color(1.0, 0.25, 0.25, 0.35)
@export var alert_overlay_z_index: int = 25

@onready var label_background: ColorRect = $LabelBackground
@onready var label: Label = $Label

var label_bg_default_color: Color = Color(0.0, 0.0, 0.0, 0.0)
var label_font_size_default: int = -1
var alert_indicator_active: bool = false
var label_selection_dirty: bool = true
var alert_overlays: Array[Polygon2D] = []

var occupants: Dictionary[String, Person] = {}
var ach_schedule: Array[Dictionary] = []
var ach_schedule_idx: int = 0
var manual_override_until_next_schedule: bool = false
var is_selected: bool = false

const ROOM_VL_COLOR_POINTS := [
	{"value": 0.0, "color": Color("#44c96b")},
	{"value": 250.0, "color": Color("#ff9f1c")},
	{"value": 500.0, "color": Color("#e63946")},
	{"value": 1000.0, "color": Color("#cf4dff")}
]

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0b01
	monitoring = true
	monitorable = false

	if room_id == "":
		room_id = get_path()

	ach_current = ach_default
	label_background.top_level = true
	label_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_background.size = label_size
	label_bg_default_color = label_background.color
	label.top_level = true
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.size = label_size
	label_font_size_default = label.get_theme_font_size("font_size")

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_create_alert_overlays()
	_update_label_transform()
	_refresh_label()
	_update_alert_overlays()

func _process(_delta: float) -> void:
	_update_label_transform()

func _create_alert_overlays() -> void:
	for overlay in alert_overlays:
		if is_instance_valid(overlay):
			overlay.queue_free()
	alert_overlays.clear()

	for child in get_children():
		if child is CollisionPolygon2D:
			var collision_polygon: CollisionPolygon2D = child
			var overlay := Polygon2D.new()
			overlay.polygon = collision_polygon.polygon
			overlay.position = collision_polygon.position
			overlay.rotation = collision_polygon.rotation
			overlay.scale = collision_polygon.scale
			overlay.skew = collision_polygon.skew
			overlay.z_index = alert_overlay_z_index
			overlay.color = alert_overlay_color
			overlay.visible = alert_indicator_active
			overlay.show_behind_parent = false
			add_child(overlay)
			alert_overlays.append(overlay)

func _update_alert_overlays() -> void:
	for overlay in alert_overlays:
		if not is_instance_valid(overlay):
			continue
		overlay.visible = alert_indicator_active
		overlay.color = alert_overlay_color
		overlay.z_index = alert_overlay_z_index

func reset_for_simulation(start_time_s: float):
	viral_load = 0.0
	ach_current = ach_default
	ach_schedule_idx = 0
	manual_override_until_next_schedule = false
	_apply_schedule_until_time(start_time_s)
	_refresh_label()

func set_selected(selected: bool):
	if is_selected == selected:
		return
	is_selected = selected
	label_selection_dirty = true
	_refresh_label()

func set_alert_indicator(active: bool):
	if alert_indicator_active == active:
		_update_alert_overlays()
		return
	alert_indicator_active = active
	_refresh_label()
	_update_alert_overlays()

func set_ach_schedule(entries: Array):
	ach_schedule.clear()

	for entry in entries:
		if not entry is Dictionary:
			continue

		ach_schedule.append({
			"start_time": float(entry.get("start_time", 0.0)),
			"ach": max(0.0, float(entry.get("ach", ach_default)))
		})

	ach_schedule.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["start_time"]) < float(b["start_time"]))
	ach_schedule_idx = 0
	manual_override_until_next_schedule = false
	_apply_schedule_until_time(Global.current_time_s())
	_refresh_label()

func adjust_ach(delta: float):
	ach_current = max(0.0, ach_current + delta)
	manual_override_until_next_schedule = true
	_refresh_label()

func _physics_process(_delta: float) -> void:
	if not Global.can_advance_simulation():
		return

	_apply_schedule_until_time(Global.current_time_s())

	var infected_count := 0
	for pid in occupants:
		var person: Person = occupants[pid]
		if is_instance_valid(person) and person.disease_state == "I":
			infected_count += 1

	var vent_decay_per_s: float = ach_current / 3600.0
	var total_decay_per_s: float = vent_decay_per_s + non_vent_decay_per_s
	var source_per_s: float = infected_emission_per_s * infected_count
	var dt: float = Global.seconds_per_physics_tick

	viral_load = max(0.0, viral_load + dt * (source_per_s - total_decay_per_s * viral_load))
	_refresh_label(infected_count)

func _apply_schedule_until_time(current_time_s: float):
	while ach_schedule_idx < ach_schedule.size() and current_time_s >= float(ach_schedule[ach_schedule_idx]["start_time"]):
		if not manual_override_until_next_schedule:
			ach_current = float(ach_schedule[ach_schedule_idx]["ach"])
		else:
			# Manual override lasts until the next schedule boundary.
			manual_override_until_next_schedule = false
			ach_current = float(ach_schedule[ach_schedule_idx]["ach"])
		ach_schedule_idx += 1

func _refresh_label(infected_count: int = -1):
	if label == null:
		return

	if infected_count < 0:
		infected_count = _infected_count_now()

	var short_room_name := _short_room_name(room_id)
	var selection_marker := "▶ " if is_selected else ""
	var alert_symbol := "◆" if alert_indicator_active else "◇"
	label.text = "%s%s %s\nACH: %.1f  I: %d\nV: %.2f" % [selection_marker, alert_symbol, short_room_name, ach_current, infected_count, viral_load]
	label.add_theme_color_override("font_color", _room_vl_color(viral_load))
	_apply_label_selection_style()

func _update_label_transform() -> void:
	if label == null or label_background == null:
		return

	label_background.global_position = global_position + label_offset
	label_background.size = label_size
	label.global_position = global_position + label_offset
	label.size = label_size

func _apply_label_selection_style() -> void:
	if label == null or label_background == null:
		return
	if not label_selection_dirty:
		return

	if is_selected:
		label_background.color = label_selected_background
		if label_font_size_default <= 0:
			label_font_size_default = label.get_theme_font_size("font_size")
		if label_font_size_default > 0 and label_selected_font_scale > 0.0:
			var scaled_size := int(round(label_font_size_default * label_selected_font_scale))
			label.add_theme_font_size_override("font_size", scaled_size)
		label.add_theme_constant_override("outline_size", 2)
		label.add_theme_color_override("font_outline_color", Color.BLACK)
	else:
		label_background.color = label_bg_default_color
		label.remove_theme_font_size_override("font_size")
		label.remove_theme_constant_override("outline_size")
		label.remove_theme_color_override("font_outline_color")

	label_selection_dirty = false

func _short_room_name(value: String) -> String:
	var normalized := value.replace("\\", "/")
	var parts := normalized.split("/")
	if parts.is_empty():
		return value
	return parts[parts.size() - 1]

func display_name() -> String:
	return _short_room_name(room_id)

func occupant_pid_csv() -> String:
	var pid_list := PackedStringArray(occupants.keys())
	pid_list.sort()
	return ",".join(pid_list)

func _room_vl_color(current_viral_load: float) -> Color:
	if ROOM_VL_COLOR_POINTS.size() == 0:
		return Color.WHITE

	if current_viral_load <= float(ROOM_VL_COLOR_POINTS[0]["value"]):
		return ROOM_VL_COLOR_POINTS[0]["color"]

	for idx in range(ROOM_VL_COLOR_POINTS.size() - 1):
		var start_point: Dictionary = ROOM_VL_COLOR_POINTS[idx]
		var end_point: Dictionary = ROOM_VL_COLOR_POINTS[idx + 1]
		var start_value: float = float(start_point["value"])
		var end_value: float = float(end_point["value"])

		if current_viral_load <= end_value:
			var t := inverse_lerp(start_value, end_value, current_viral_load)
			return start_point["color"].lerp(end_point["color"], t)

	return ROOM_VL_COLOR_POINTS[ROOM_VL_COLOR_POINTS.size() - 1]["color"]

func _infected_count_now() -> int:
	var count := 0
	for pid in occupants:
		var person: Person = occupants[pid]
		if is_instance_valid(person) and person.disease_state == "I":
			count += 1
	return count

func _on_body_entered(body: Node2D):
	if body is Person:
		var person: Person = body
		occupants[person.pid] = person

func _on_body_exited(body: Node2D):
	if body is Person:
		var person: Person = body
		occupants.erase(person.pid)
