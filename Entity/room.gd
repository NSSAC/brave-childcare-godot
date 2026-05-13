class_name Room extends Area2D

@export var room_id: String = ""
@export var ach_default: float = 3.0
@export var ach_current: float = 3.0
@export var viral_load: float = 0.0
@export var infected_emission_per_s: float = 1.0
@export var non_vent_decay_per_s: float = 0.0
@export var label_offset: Vector2 = Vector2(-120.0, -90.0)
@export var label_size: Vector2 = Vector2(330.0, 148.0)
@export var label_z_index: int = 20
@export var label_background_color: Color = Color(1.0, 1.0, 1.0, 0.68)
@export var label_selected_background: Color = Color(1.0, 1.0, 1.0, 0.84)
@export var label_border_color: Color = Color(0.05, 0.08, 0.12, 0.14)
@export var label_selected_border_color: Color = Color(0.12, 0.34, 0.62, 0.46)
@export var label_selected_edge_width: int = 2
@export var label_text_color: Color = Color(0.09, 0.11, 0.14, 0.96)
@export var label_muted_text_color: Color = Color(0.09, 0.11, 0.14, 0.72)
@export var ach_gauge_color: Color = Color("#4c8bf5")
@export var gauge_track_color: Color = Color(0.05, 0.08, 0.12, 0.12)
@export var label_selected_font_scale: float = 1.1
@export var alert_overlay_color: Color = Color(1.0, 0.25, 0.25, 0.35)
@export var alert_overlay_z_index: int = 25

@onready var label_background: Panel = $LabelBackground
@onready var title_label: Label = $LabelBackground/TitleLabel
@onready var schedule_label: Label = $LabelBackground/ScheduleLabel
@onready var vl_prefix_label: Label = $LabelBackground/VLPrefixLabel
@onready var vl_gauge_track: ColorRect = $LabelBackground/VLGaugeTrack
@onready var vl_gauge_fill: ColorRect = $LabelBackground/VLGaugeTrack/VLGaugeFill
@onready var ach_prefix_label: Label = $LabelBackground/ACHPrefixLabel
@onready var ach_gauge_track: ColorRect = $LabelBackground/ACHGaugeTrack
@onready var ach_gauge_fill: ColorRect = $LabelBackground/ACHGaugeTrack/ACHGaugeFill
@onready var vl_value_label: Label = $LabelBackground/VLValueLabel
@onready var ach_value_label: Label = $LabelBackground/ACHValueLabel

var title_font_size_default: int = -1
var alert_indicator_active: bool = false
var label_selection_dirty: bool = true
var alert_overlays: Array[Polygon2D] = []

var occupants: Dictionary[String, Person] = {}
var ach_schedule: Array[Dictionary] = []
var ach_schedule_idx: int = 0
var is_selected: bool = false
var ach_last_update_source: String = "manual"
var health_mode_enabled: bool = false
var brave_mode_enabled: bool = false
var health_alert_active: bool = false
var health_manual_override: bool = false
var ach_min: float = 0.0
var ach_max: float = 7.0
var ach_health_baseline: float = 3.0
var schedule_description: String = ""

const ACH_SOURCE_MANUAL: String = "manual"
const ACH_SOURCE_SCHEDULE: String = "schedule"

const ROOM_VL_COLOR_POINTS := [
	{"value": 0.0, "color": Color("#44c96b")},
	{"value": 250.0, "color": Color("#ff9f1c")},
	{"value": 500.0, "color": Color("#e63946")},
	{"value": 1000.0, "color": Color("#cf4dff")}
]

const PANEL_PADDING_X: float = 12.0
const PANEL_PADDING_Y: float = 10.0
const PANEL_GUTTER_X: float = 10.0
const PANEL_TITLE_HEIGHT: float = 22.0
const PANEL_SCHEDULE_HEIGHT: float = 18.0
const PANEL_GAUGE_ROW_HEIGHT: float = 20.0
const PANEL_GAUGE_LABEL_WIDTH: float = 42.0
const PANEL_GAUGE_LABEL_GAP: float = 16.0
const PANEL_GAUGE_HEIGHT: float = 10.0
const PANEL_GAUGE_TOP_INSET: float = 7.0
const PANEL_LEFT_COLUMN_RATIO: float = 0.58
const PANEL_VL_MAX_REFERENCE: float = 1000.0

func _ready() -> void:
	collision_layer = 0
	collision_mask = 0b01
	monitoring = true
	monitorable = false

	if room_id == "":
		room_id = get_path()

	ach_current = ach_default
	label_background.top_level = true
	label_background.z_index = label_z_index
	label_background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label_background.size = label_size
	title_font_size_default = title_label.get_theme_font_size("font_size")
	_update_panel_layout()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	_create_alert_overlays()
	_update_label_transform()
	_refresh_label()
	_update_alert_overlays()

func _process(_delta: float) -> void:
	_update_label_transform()
	if label_background != null and label_background.z_index != label_z_index:
		label_background.z_index = label_z_index

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
	ach_current = _clamp_ach(ach_default)
	ach_last_update_source = ACH_SOURCE_MANUAL
	ach_schedule_idx = 0
	health_alert_active = false
	health_manual_override = false
	_apply_schedule_until_time(start_time_s)
	_refresh_label()

func configure_ach_bounds(min_ach: float, max_ach: float, baseline_ach: float) -> void:
	ach_min = minf(min_ach, max_ach)
	ach_max = maxf(min_ach, max_ach)
	ach_health_baseline = _clamp_ach(baseline_ach)
	ach_default = _clamp_ach(ach_default)
	ach_current = _clamp_ach(ach_current)
	_refresh_label()

func set_health_mode_enabled(enabled: bool, current_time_s: float, brave_mode: bool = false) -> void:
	if health_mode_enabled == enabled and brave_mode_enabled == (enabled and brave_mode):
		return

	health_mode_enabled = enabled
	brave_mode_enabled = enabled and brave_mode
	health_manual_override = false

	if health_mode_enabled:
		health_alert_active = false
		ach_current = _clamp_ach(ach_health_baseline)
	else:
		brave_mode_enabled = false
		health_alert_active = false
		_apply_schedule_until_time(current_time_s)

	_refresh_label()

func apply_health_mode_alert(alert_active: bool) -> void:
	if not health_mode_enabled:
		return

	if alert_active != health_alert_active:
		health_alert_active = alert_active
		health_manual_override = false
		if health_alert_active:
			ach_current = _clamp_ach(ach_max)
		else:
			ach_current = _clamp_ach(ach_health_baseline)
		ach_last_update_source = ACH_SOURCE_MANUAL
		_refresh_label()

func apply_brave_mode_alert(alert_active: bool, min_ach: float) -> void:
	if not health_mode_enabled or not brave_mode_enabled:
		return

	var brave_floor_ach := _clamp_ach(min_ach)
	if alert_active != health_alert_active or (not alert_active and not is_equal_approx(ach_current, brave_floor_ach)):
		health_alert_active = alert_active
		health_manual_override = false
		if health_alert_active:
			ach_current = _clamp_ach(ach_max)
		else:
			ach_current = brave_floor_ach
		ach_last_update_source = ACH_SOURCE_MANUAL
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
			"ach": _clamp_ach(float(entry.get("ach", ach_default)))
		})

	ach_schedule.sort_custom(func(a: Dictionary, b: Dictionary): return float(a["start_time"]) < float(b["start_time"]))
	ach_schedule_idx = 0
	_apply_schedule_until_time(Global.current_time_s())
	_refresh_label()

func set_schedule_description(description: String) -> void:
	var cleaned := description.strip_edges()
	if schedule_description == cleaned:
		return
	schedule_description = cleaned
	_refresh_label()

func adjust_ach(delta: float):
	ach_current = _clamp_ach(ach_current + delta)
	ach_last_update_source = ACH_SOURCE_MANUAL
	health_manual_override = health_mode_enabled
	_refresh_label()

func has_ach_schedule() -> bool:
	return ach_schedule.size() > 0

func ach_mode_marker() -> String:
	if brave_mode_enabled:
		return "🄱"
	if health_mode_enabled:
		return "🄷"
	return "🅂" if ach_last_update_source == ACH_SOURCE_SCHEDULE else "🄼"

func _physics_process(_delta: float) -> void:
	if not Global.can_advance_simulation():
		return

	if not health_mode_enabled:
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
		# Only overwrite ACH when the schedule advances to a newly-due row.
		# This allows manual +/- changes to persist between scheduled transitions.
		ach_current = _clamp_ach(float(ach_schedule[ach_schedule_idx]["ach"]))
		ach_last_update_source = ACH_SOURCE_SCHEDULE
		ach_schedule_idx += 1

func _clamp_ach(value: float) -> float:
	return clampf(value, ach_min, ach_max)

func _refresh_label(infected_count: int = -1):
	if title_label == null:
		return

	if infected_count < 0:
		infected_count = _infected_count_now()

	var short_room_name := _short_room_name(room_id)
	title_label.text = short_room_name
	schedule_label.text = schedule_description if schedule_description != "" else "Schedule: n/a"
	vl_prefix_label.text = "Load"
	ach_prefix_label.text = "ACH"
	vl_value_label.text = "%d" % int(round(viral_load))
	ach_value_label.text = "%d" % int(round(ach_current))

	var vl_color := _room_vl_color(viral_load)
	_apply_gauge_fill(vl_gauge_track, vl_gauge_fill, _vl_ratio(), vl_color)
	_apply_gauge_fill(ach_gauge_track, ach_gauge_fill, _ach_ratio(), ach_gauge_color)

	title_label.add_theme_color_override("font_color", label_text_color)
	schedule_label.add_theme_color_override("font_color", label_muted_text_color)
	vl_prefix_label.add_theme_color_override("font_color", label_text_color)
	ach_prefix_label.add_theme_color_override("font_color", label_text_color)
	vl_value_label.add_theme_color_override("font_color", vl_color)
	ach_value_label.add_theme_color_override("font_color", label_text_color)
	_apply_label_selection_style()

func _update_label_transform() -> void:
	if label_background == null:
		return

	label_background.global_position = global_position + label_offset
	label_background.size = label_size
	_update_panel_layout()

func _apply_label_selection_style() -> void:
	if label_background == null:
		return
	if not label_selection_dirty:
		return

	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	var border_width := label_selected_edge_width if is_selected else 1
	style.border_width_left = border_width
	style.border_width_top = border_width
	style.border_width_right = border_width
	style.border_width_bottom = border_width
	style.bg_color = label_selected_background if is_selected else label_background_color
	style.border_color = label_selected_border_color if is_selected else label_border_color
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.22) if is_selected else Color(0.0, 0.0, 0.0, 0.08)
	style.shadow_size = 3 if is_selected else 1
	label_background.add_theme_stylebox_override("panel", style)

	if is_selected:
		if title_font_size_default <= 0:
			title_font_size_default = title_label.get_theme_font_size("font_size")
		if title_font_size_default > 0 and label_selected_font_scale > 0.0:
			var scaled_size := int(round(title_font_size_default * label_selected_font_scale))
			title_label.add_theme_font_size_override("font_size", scaled_size)
		title_label.add_theme_constant_override("outline_size", 2)
		title_label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 0.15))
	else:
		title_label.remove_theme_font_size_override("font_size")
		title_label.remove_theme_constant_override("outline_size")
		title_label.remove_theme_color_override("font_outline_color")

	label_selection_dirty = false

func _update_panel_layout() -> void:
	if label_background == null:
		return

	var total_width := maxf(label_size.x, 250.0)
	var total_height := maxf(label_size.y, 126.0)
	var inner_width := total_width - PANEL_PADDING_X * 2.0
	var left_width := maxf((inner_width - PANEL_GUTTER_X) * PANEL_LEFT_COLUMN_RATIO, 110.0)
	var right_width := maxf(inner_width - PANEL_GUTTER_X - left_width, 92.0)
	var right_x := PANEL_PADDING_X + left_width + PANEL_GUTTER_X
	var title_y := PANEL_PADDING_Y
	var schedule_y := title_y + PANEL_TITLE_HEIGHT + 2.0
	var vl_row_y := schedule_y + PANEL_SCHEDULE_HEIGHT + 7.0
	var ach_row_y := vl_row_y + PANEL_GAUGE_ROW_HEIGHT + 7.0

	title_label.position = Vector2(PANEL_PADDING_X, title_y)
	title_label.size = Vector2(inner_width, PANEL_TITLE_HEIGHT)
	schedule_label.position = Vector2(PANEL_PADDING_X, schedule_y)
	schedule_label.size = Vector2(inner_width, PANEL_SCHEDULE_HEIGHT)

	vl_prefix_label.position = Vector2(PANEL_PADDING_X, vl_row_y)
	vl_prefix_label.size = Vector2(PANEL_GAUGE_LABEL_WIDTH, PANEL_GAUGE_ROW_HEIGHT)
	vl_gauge_track.position = Vector2(PANEL_PADDING_X + PANEL_GAUGE_LABEL_WIDTH + PANEL_GAUGE_LABEL_GAP, vl_row_y + PANEL_GAUGE_TOP_INSET)
	vl_gauge_track.size = Vector2(maxf(left_width - PANEL_GAUGE_LABEL_WIDTH - PANEL_GAUGE_LABEL_GAP, 20.0), PANEL_GAUGE_HEIGHT)
	vl_value_label.position = Vector2(right_x, vl_row_y)
	vl_value_label.size = Vector2(right_width, PANEL_GAUGE_ROW_HEIGHT)

	ach_prefix_label.position = Vector2(PANEL_PADDING_X, ach_row_y)
	ach_prefix_label.size = Vector2(PANEL_GAUGE_LABEL_WIDTH, PANEL_GAUGE_ROW_HEIGHT)
	ach_gauge_track.position = Vector2(PANEL_PADDING_X + PANEL_GAUGE_LABEL_WIDTH + PANEL_GAUGE_LABEL_GAP, ach_row_y + PANEL_GAUGE_TOP_INSET)
	ach_gauge_track.size = Vector2(maxf(left_width - PANEL_GAUGE_LABEL_WIDTH - PANEL_GAUGE_LABEL_GAP, 20.0), PANEL_GAUGE_HEIGHT)
	ach_value_label.position = Vector2(right_x, ach_row_y)
	ach_value_label.size = Vector2(right_width, PANEL_GAUGE_ROW_HEIGHT)

	vl_gauge_fill.position = Vector2.ZERO
	vl_gauge_fill.size.y = vl_gauge_track.size.y
	ach_gauge_fill.position = Vector2.ZERO
	ach_gauge_fill.size.y = ach_gauge_track.size.y

func _apply_gauge_fill(track: ColorRect, fill: ColorRect, ratio: float, fill_color: Color) -> void:
	if track == null or fill == null:
		return
	track.color = gauge_track_color
	fill.color = fill_color
	fill.size = Vector2(maxf(track.size.x * clampf(ratio, 0.0, 1.0), 0.0), track.size.y)

func _vl_ratio() -> float:
	return clampf(viral_load / PANEL_VL_MAX_REFERENCE, 0.0, 1.0)

func _ach_ratio() -> float:
	if is_equal_approx(ach_max, ach_min):
		return 1.0
	return clampf((ach_current - ach_min) / (ach_max - ach_min), 0.0, 1.0)

func _short_room_name(value: String) -> String:
	var normalized := value.replace("\\", "/")
	var parts := normalized.split("/")
	if parts.is_empty():
		return _prettify_room_name(value)
	return _prettify_room_name(parts[parts.size() - 1])

func _prettify_room_name(raw_name: String) -> String:
	var text := raw_name.replace("_", " ").strip_edges()
	if text == "":
		return raw_name

	# Insert spaces between camel-case words while keeping acronyms intact.
	var spaced := ""
	for idx in range(text.length()):
		var ch := text[idx]
		if idx > 0 and ch >= "A" and ch <= "Z":
			var prev := text[idx - 1]
			if prev != " " and not (prev >= "A" and prev <= "Z"):
				spaced += " "
		spaced += ch

	# Collapse redundant trailing "Room" labels (e.g., "Preschool Room" -> "Preschool").
	if spaced.ends_with(" Room"):
		spaced = spaced.left(spaced.length() - 5).strip_edges()

	return spaced

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
		var person = body
		occupants[person.pid] = person
		person.enter_room(self)

func _on_body_exited(body: Node2D):
	if body is Person:
		var person = body
		occupants.erase(person.pid)
		person.exit_room(self)
