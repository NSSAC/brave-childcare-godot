extends Node

@onready var object_file_dialog: FileDialog = %ObjectFileDialog
@onready var config_file_dialog: FileDialog = %ConfigFileDialog

@onready var save_object_button: Button = %SaveObjectButton
@onready var start_simulation_button: Button = %StartSimulationButton
@onready var start_simulation_default_button: Button = %StartSimulationDefaultButton
@onready var title_label: Label = $TitleScreen/TitleLabel
@onready var player_name_input: LineEdit = %PlayerNameInput
@onready var player_name_auto_label: Label = %PlayerNameAutoLabel

@onready var title_screen: CanvasLayer = %TitleScreen
@onready var map: Node2D = %Map
@onready var camera_2d: Camera2D = %Camera2D
@onready var end_simulation_button: Button = %EndSimulationButton
@onready var last_run_summary_label: Label = %LastRunSummaryLabel
@onready var pause_overlay: Control = %PauseOverlay
@onready var room_panel: PanelContainer = %RoomPanel
@onready var room_panel_text: RichTextLabel = %RoomPanelText
@onready var panel_player_name_label: Label = %PanelPlayerNameLabel
@onready var room_panel_margin: MarginContainer = $Map/CanvasLayer/RoomPanel/MarginContainer
@onready var panel_sensor_value: Control = %PanelSensorValue
@onready var panel_alert_count_matrix: Control = %PanelAlertCountMatrix
@onready var panel_ach_gauge: Control = %PanelAchGauge
@onready var panel_vl_gauge: Control = %PanelViralLoadGauge
@onready var panel_alert_lamp: Panel = %PanelAlertLamp
@onready var panel_room_cards: VBoxContainer = %PanelRoomCards
@onready var panel_prev_room_button: Button = %PanelPrevRoomButton
@onready var panel_next_room_button: Button = %PanelNextRoomButton
@onready var panel_ach_down_button: Button = %PanelAchDownButton
@onready var panel_ach_up_button: Button = %PanelAchUpButton
@onready var panel_health_toggle_button: Button = %PanelHealthToggleButton
@onready var panel_speed_down_button: Button = %PanelSpeedDownButton
@onready var panel_speed_up_button: Button = %PanelSpeedUpButton
@onready var panel_pause_button: Button = %PanelPauseButton
@onready var panel_total_cost_value: Label = %PanelTotalCostValue
@onready var panel_ach_rate_value: Label = %PanelAchRateValue
@onready var panel_current_hourly_cost_value: Label = %PanelCurrentHourlyCostValue
@onready var panel_exposure_avg_value: Label = %PanelExposureAvgValue
@onready var panel_exposure_max_value: Label = %PanelExposureMaxValue
@onready var panel_exposure_total_value: Label = %PanelExposureTotalValue
@onready var panel_ach_control_value: Label = %PanelAchControlValue
@onready var panel_sim_state_clock: Control = %PanelSimStateClock
@onready var panel_sim_state_time_value: Label = %PanelSimStateTimeValue
@onready var panel_sim_state_fps_value: Label = %PanelSimStateFpsValue
@onready var panel_sim_state_speed_value: Label = %PanelSimStateSpeedValue
@onready var tutorial_overlay: CanvasLayer = %TutorialOverlay
@onready var tutorial_highlight_frame: Panel = %TutorialHighlightFrame
@onready var tutorial_step_label: Label = %TutorialStepLabel
@onready var tutorial_title_label: Label = %TutorialTitleLabel
@onready var tutorial_body_label: Label = %TutorialBodyLabel
@onready var tutorial_slide_image: TextureRect = %TutorialSlideImage
@onready var tutorial_slide_video: VideoStreamPlayer = %TutorialSlideVideo
@onready var tutorial_back_button: Button = %TutorialBackButton
@onready var tutorial_next_button: Button = %TutorialNextButton
@onready var tutorial_skip_button: Button = %TutorialSkipButton

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

@export var default_config_path: String = "res://inputs/config_childcare.json"
@export var default_room_description_file: String = "res://inputs/schedule_rooms.json"
@export var room_alert_threshold_vl: float = 600.0
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
@export var panel_vl_gauge_max: float = 1000.0
@export var panel_ach_gauge_max: float = 7.0
@export var panel_alert_lamp_pulse_hz: float = 1.6

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
var brave_mode_active: bool = false
var health_mode_baseline_ach: float = 3.0
var health_mode_max_ach: float = 7.0
var health_mode_min_ach: float = 0.0
var brave_mode_threshold: float = 100.0
var brave_mode_min_ach: float = 1.0
var active_config_path: String = ""
var active_config_for_archive: Dictionary = {}
var panel_alert_lamp_style_on: StyleBoxFlat
var panel_alert_lamp_style_off: StyleBoxFlat
var panel_room_card_nodes: Array = []
var panel_alert_lamp_is_alerting: bool = false
var panel_value_cache: Dictionary = {}
var room_description_rows: Array = []
var splash_version_text_override: String = ""
var tutorial_mode_active: bool = false
var tutorial_resume_paused_state: bool = false
var tutorial_steps: Array[Dictionary] = []
var tutorial_step_idx: int = 0
var tutorial_highlight_style: StyleBoxFlat
var tutorial_texture_cache: Dictionary = {}

const ROOM_ACH_STEP: float = 1.0
const ROOM_VL_TREND_EPSILON: float = 0.01
const ROOM_COST_UPDATE_INTERVAL_S: float = 60.0
const TUTORIAL_HIGHLIGHT_PADDING: float = 12.0
const RANDOM_PLAYER_NAMES: Array[String] = [
	"Merida", "Elinor", "Fergus", "Harris", "Hubert", "Hamish", "Angus", "Wispa", "Macintosh", "MacGuffin",
	"Dingwall", "Mor'du", "Maudie", "Young Macintosh", "Young MacGuffin", "Young Dingwall", "Wee Dingwall", "Kelly", "Macdonald", "Billy",
	"Connolly", "Emma", "Thompson", "Julie", "Walters", "Robbie", "Coltrane", "Kevin", "McKidd", "Craig", "Ferguson"
]
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
	room_panel.anchor_top = 0.0
	room_panel.anchor_bottom = 1.0
	room_panel.offset_left = -room_panel_screen_margin - panel_width
	room_panel.offset_right = -room_panel_screen_margin
	room_panel.offset_top = room_panel_screen_margin
	room_panel.offset_bottom = -room_panel_screen_margin

	var height_scale := clampf(inverse_lerp(720.0, 1600.0, viewport_size.y), 0.0, 1.0)
	var width_scale_start: float = minf(room_panel_width_scale_start_px, room_panel_width_scale_end_px)
	var width_scale_end: float = maxf(room_panel_width_scale_start_px, room_panel_width_scale_end_px)
	var width_scale := clampf(inverse_lerp(width_scale_start, width_scale_end, panel_width), 0.0, 1.0)
	var ui_scale: float = minf(height_scale, width_scale)
	var target_font_size := int(round(lerpf(room_panel_font_size_min, room_panel_font_size_max, ui_scale)))
	var caption_font_size := int(clampf(round(target_font_size * 0.48), 13.0, 22.0))
	var section_font_size := int(clampf(round(target_font_size * 0.62), 18.0, 30.0))
	var panel_title_font_size := int(clampf(round(target_font_size * 0.78), 22.0, 38.0))
	var value_font_size := int(clampf(round(target_font_size * 0.68), 16.0, 32.0))
	var metric_value_font_size := int(clampf(round(float(value_font_size) * 1.2), 18.0, 38.0))
	var line_separation := int(round(lerpf(room_panel_line_separation_min, room_panel_line_separation_max, ui_scale)))
	var margin_size := int(round(lerpf(room_panel_margin_min, room_panel_margin_max, ui_scale)))

	room_panel_text.add_theme_font_size_override("normal_font_size", value_font_size)
	room_panel_text.add_theme_font_size_override("bold_font_size", value_font_size)
	room_panel_text.add_theme_constant_override("line_separation", line_separation)
	room_panel_text.scroll_active = viewport_size.y < 900.0 or viewport_size.x < 1500.0

	room_panel_margin.add_theme_constant_override("margin_left", margin_size)
	room_panel_margin.add_theme_constant_override("margin_top", margin_size)
	room_panel_margin.add_theme_constant_override("margin_right", margin_size)
	room_panel_margin.add_theme_constant_override("margin_bottom", margin_size)

	var value_labels: Array[Label] = [
		panel_total_cost_value,
		panel_ach_rate_value,
		panel_current_hourly_cost_value,
		panel_exposure_avg_value,
		panel_exposure_max_value,
		panel_exposure_total_value,
		panel_ach_control_value,
		panel_sim_state_time_value,
		panel_sim_state_fps_value,
		panel_sim_state_speed_value,
	]
	for label in value_labels:
		if is_instance_valid(label):
			label.add_theme_font_size_override("font_size", value_font_size)

	var metric_value_labels: Array[Label] = [
		panel_total_cost_value,
		panel_ach_rate_value,
		panel_current_hourly_cost_value,
		panel_exposure_avg_value,
		panel_exposure_max_value,
		panel_exposure_total_value,
	]
	for label in metric_value_labels:
		if is_instance_valid(label):
			label.add_theme_font_size_override("font_size", metric_value_font_size)

	var section_label_paths := [
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/PanelTitle",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/SimStateCenterBox/ClockBox/StateTitle",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/RoomCardsLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/ActionsLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/AchControlLabel",
	]
	for node_path in section_label_paths:
		var section_label = get_node_or_null(node_path)
		if section_label is Label:
			var label := section_label as Label
			label.add_theme_font_size_override("font_size", panel_title_font_size if node_path.ends_with("/PanelTitle") else section_font_size)
			label.add_theme_color_override("font_color", Color(0.9, 0.95, 1.0, 1.0))

	var caption_paths := [
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/SimStateCenterBox/StatsBox/SimTimeLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/SimStateCenterBox/StatsBox/SimFpsLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/SimStateCenterBox/StatsBox/SimSpeedStateLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/AlertBox/AlertCounterTitle",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/AlertBox/AlertLampRow/AlertLampLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/DialRow/AchDialVBox/AchGaugeLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/DialRow/ViralDialVBox/ViralLoadGaugeLabel",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsGrid/MetricCardAchRate/Margin/VBox/Title",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsGrid/MetricCardCurrentHourly/Margin/VBox/Title",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsGrid/MetricCardTotalCost/Margin/VBox/Title",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsGrid/MetricCardExposureAvg/Margin/VBox/Title",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsGrid/MetricCardExposureMax/Margin/VBox/Title",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/MetricsGrid/MetricCardExposureTotal/Margin/VBox/Title",
		"Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/SensorCountdownCard/Margin/VBox/Title",
	]
	for node_path in caption_paths:
		var caption = get_node_or_null(node_path)
		if caption is Label:
			(caption as Label).add_theme_font_size_override("font_size", caption_font_size)

func _update_simulation_state_card() -> void:
	var sim_time_s: float = Global.current_time_s()
	var sim_h: int = int(sim_time_s / 3600.0)
	var sim_m: int = int((sim_time_s - float(sim_h) * 3600.0) / 60.0)
	_set_panel_value(panel_sim_state_time_value, "%02d:%02d" % [sim_h, sim_m], Color(0.9, 0.95, 1, 1))
	if panel_sensor_value != null and panel_sensor_value.has_method("set_value"):
		panel_sensor_value.call("set_value", _next_sensor_reading_counter_value())
	_set_panel_value(panel_sim_state_fps_value, str(Engine.get_frames_per_second()), Color(0.88, 0.97, 1, 1))
	_set_panel_value(panel_sim_state_speed_value, "x%.2f" % Global.sim_speed_scale, Color(0.8, 0.93, 1, 1))
	if panel_alert_count_matrix != null and panel_alert_count_matrix.has_method("set_value"):
		panel_alert_count_matrix.call("set_value", room_alert_trigger_count_total)
	if panel_sim_state_clock != null and panel_sim_state_clock.has_method("set_time_seconds"):
		panel_sim_state_clock.call("set_time_seconds", sim_time_s)

func _set_panel_value(label: Label, text_value: String, flash_color: Color = Color(1, 1, 1, 1)) -> void:
	if label == null:
		return
	var key := str(label.get_path())
	var previous := str(panel_value_cache.get(key, ""))
	if previous == text_value:
		return
	panel_value_cache[key] = text_value
	label.text = text_value
	label.modulate = flash_color
	var tween := create_tween()
	tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 0.24).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _build_alert_lamp_style(fill_color: Color, border_color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill_color
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = border_color
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	return style

func _room_card_style(selected: bool, alerting: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#151b22") if not selected else Color("#1d2833")
	style.border_width_left = 1
	style.border_width_top = 1
	style.border_width_right = 1
	style.border_width_bottom = 1
	style.border_color = Color("#2f3d4a")
	if selected:
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color("#5ca9ff")
	if alerting:
		style.border_color = Color("#b53030")
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	return style

func _ensure_room_card_count(target_count: int) -> void:
	if panel_room_cards == null:
		return

	while panel_room_card_nodes.size() < target_count:
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(0.0, 96.0)
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.gui_input.connect(_on_room_card_gui_input.bind(card))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 10)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 10)
		margin.add_theme_constant_override("margin_bottom", 8)
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE

		var label := RichTextLabel.new()
		label.bbcode_enabled = true
		label.fit_content = true
		label.scroll_active = false
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		label.add_theme_font_size_override("normal_font_size", 21)
		label.add_theme_font_size_override("bold_font_size", 21)
		label.add_theme_constant_override("line_separation", 2)

		margin.add_child(label)
		card.add_child(margin)
		panel_room_cards.add_child(card)
		panel_room_card_nodes.append(card)

	while panel_room_card_nodes.size() > target_count:
		var node = panel_room_card_nodes.pop_back()
		if is_instance_valid(node):
			node.queue_free()

func _update_room_cards(selected_room) -> void:
	if panel_room_cards == null:
		return

	if room_nodes.is_empty():
		_ensure_room_card_count(0)
		return

	_ensure_room_card_count(room_nodes.size())

	for idx in range(room_nodes.size()):
		var room = room_nodes[idx]
		var card: PanelContainer = panel_room_card_nodes[idx]
		card.set_meta("room_card_idx", idx)
		var margin: MarginContainer = card.get_child(0)
		var label: RichTextLabel = margin.get_child(0)
		var is_selected := idx == selected_room_idx
		var trend_symbol := _room_vl_trend_symbol(room.room_id, room.viral_load)
		var is_alerting := _room_alert_state(room)
		var vl_color := _room_vl_color(room.viral_load)
		var mode_text := _room_ach_mode_marker(room)
		var room_description := _room_schedule_description(room)
		if room.has_method("set_schedule_description"):
			room.call("set_schedule_description", room_description)

		card.add_theme_stylebox_override("panel", _room_card_style(is_selected, is_alerting))

		var title_line: String = _short_room_name(room.room_id)
		if room.has_method("display_name"):
			title_line = str(room.display_name())
		if room_description != "":
			title_line += " - " + room_description
		var title_prefix := "[b]" + ("● " if is_selected else "○ ") + title_line + "[/b]"
		var alert_text := "[color=#ff6b6b]ALERT[/color]" if is_alerting else "[color=#9ba7b4]Normal[/color]"
		var details := "ACH %s %.1f  |  Load [color=#%s]%.1f %s[/color]" % [mode_text, room.ach_current, vl_color.to_html(false), room.viral_load, trend_symbol]
		label.text = "%s\n%s  |  %s" % [title_prefix, details, alert_text]

func _on_room_card_gui_input(event: InputEvent, card: PanelContainer) -> void:
	if event is InputEventMouseButton:
		var mouse_event := event as InputEventMouseButton
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			if not card.has_meta("room_card_idx"):
				return
			selected_room_idx = int(card.get_meta("room_card_idx"))
			selected_room_idx = clampi(selected_room_idx, 0, max(room_nodes.size() - 1, 0))
			_update_room_panel(true)

func _update_alert_lamp_visual(now_s: float) -> void:
	if panel_alert_lamp == null:
		return

	if not panel_alert_lamp_is_alerting:
		if panel_alert_lamp_style_off != null:
			panel_alert_lamp.add_theme_stylebox_override("panel", panel_alert_lamp_style_off)
		return

	var pulse := 0.72 + 0.28 * sin(now_s * TAU * panel_alert_lamp_pulse_hz)
	var r := clampf(0.7 + 0.3 * pulse, 0.0, 1.0)
	var g := clampf(0.06 + 0.07 * pulse, 0.0, 1.0)
	var b := clampf(0.06 + 0.07 * pulse, 0.0, 1.0)
	var fill := Color(r, g, b, 1.0)
	var border := Color(clampf(0.45 + 0.25 * pulse, 0.0, 1.0), 0.08, 0.08, 1.0)
	panel_alert_lamp.add_theme_stylebox_override("panel", _build_alert_lamp_style(fill, border))

func _refresh_panel_controls_state() -> void:
	if panel_health_toggle_button != null:
		panel_health_toggle_button.text = "Health: ON" if health_mode_active else "Health: OFF"
	if panel_pause_button != null:
		panel_pause_button.text = "Resume" if Global.is_simulation_paused else "Pause"
		if Global.is_simulation_paused:
			panel_pause_button.add_theme_color_override("font_color", Color("#fff0bf"))
			panel_pause_button.add_theme_color_override("font_hover_color", Color("#fff7de"))
		else:
			panel_pause_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			panel_pause_button.add_theme_color_override("font_hover_color", Color(0.93, 0.96, 1, 1))

	var has_rooms: bool = room_nodes.size() > 0
	var sim_active: bool = Global.is_simulation_active
	if pause_overlay != null:
		pause_overlay.visible = sim_active and Global.is_simulation_paused

	if panel_prev_room_button != null:
		panel_prev_room_button.disabled = not has_rooms
	if panel_next_room_button != null:
		panel_next_room_button.disabled = not has_rooms
	if panel_ach_down_button != null:
		panel_ach_down_button.disabled = not has_rooms
	if panel_ach_up_button != null:
		panel_ach_up_button.disabled = not has_rooms
	if panel_health_toggle_button != null:
		panel_health_toggle_button.disabled = not sim_active
	if panel_speed_down_button != null:
		panel_speed_down_button.disabled = not sim_active
	if panel_speed_up_button != null:
		panel_speed_up_button.disabled = not sim_active
	if panel_pause_button != null:
		panel_pause_button.disabled = not sim_active

func _on_panel_prev_room_pressed() -> void:
	_cycle_selected_room(-1)

func _on_panel_next_room_pressed() -> void:
	_cycle_selected_room(1)

func _on_panel_ach_down_pressed() -> void:
	_adjust_selected_room_ach(-ROOM_ACH_STEP)

func _on_panel_ach_up_pressed() -> void:
	_adjust_selected_room_ach(ROOM_ACH_STEP)

func _on_panel_health_toggle_pressed() -> void:
	if not Global.is_simulation_active:
		return
	_set_health_mode(not health_mode_active)
	_refresh_panel_controls_state()

func _on_panel_speed_down_pressed() -> void:
	if not Global.is_simulation_active:
		return
	_adjust_sim_speed_scale(-_sim_speed_step_size())

func _on_panel_speed_up_pressed() -> void:
	if not Global.is_simulation_active:
		return
	_adjust_sim_speed_scale(_sim_speed_step_size())

func _set_pause_state(paused: bool) -> void:
	Global.is_simulation_paused = paused
	if Global.is_simulation_paused:
		save_timer.stop()
	else:
		save_timer.start()
	_refresh_panel_controls_state()

func _toggle_pause() -> void:
	if not Global.is_simulation_active:
		return
	_set_pause_state(not Global.is_simulation_paused)

func _on_panel_pause_pressed() -> void:
	_toggle_pause()

func _init_room_panel_widgets() -> void:
	if panel_ach_gauge != null:
		if panel_ach_gauge.has_method("set_range"):
			panel_ach_gauge.call("set_range", 0.0, panel_ach_gauge_max)
		if panel_ach_gauge.has_method("set_style"):
			panel_ach_gauge.call("set_style", "knob")
		if panel_ach_gauge.has_method("set_current_value"):
			panel_ach_gauge.call("set_current_value", 0.0)
	if panel_vl_gauge != null:
		if panel_vl_gauge.has_method("set_range"):
			panel_vl_gauge.call("set_range", 0.0, panel_vl_gauge_max)
		if panel_vl_gauge.has_method("set_style"):
			panel_vl_gauge.call("set_style", "speedometer")
		if panel_vl_gauge.has_method("set_current_value"):
			panel_vl_gauge.call("set_current_value", 0.0)

	panel_alert_lamp_style_off = _build_alert_lamp_style(Color("#6a6d73"), Color("#2e3033"))
	panel_alert_lamp_style_on = _build_alert_lamp_style(Color("#ff3b3b"), Color("#7a0b0b"))
	if panel_alert_lamp != null:
		panel_alert_lamp.add_theme_stylebox_override("panel", panel_alert_lamp_style_off)

func _update_room_panel_widgets(selected_room, is_alerting: bool) -> void:
	panel_alert_lamp_is_alerting = is_alerting
	if selected_room == null:
		if panel_ach_gauge != null:
			if panel_ach_gauge.has_method("set_current_value"):
				panel_ach_gauge.call("set_current_value", 0.0)
		if panel_vl_gauge != null:
			if panel_vl_gauge.has_method("set_current_value"):
				panel_vl_gauge.call("set_current_value", 0.0)
		_update_alert_lamp_visual(Global.current_time_s())
	else:
		if panel_ach_gauge != null:
			if panel_ach_gauge.has_method("set_current_value"):
				panel_ach_gauge.call("set_current_value", clampf(selected_room.ach_current, 0.0, panel_ach_gauge_max))
		if panel_vl_gauge != null:
			if panel_vl_gauge.has_method("set_current_value"):
				panel_vl_gauge.call("set_current_value", clampf(selected_room.viral_load, 0.0, panel_vl_gauge_max))
		_update_alert_lamp_visual(Global.current_time_s())

	var exposure_stats: Dictionary = _exposure_stats()
	var current_hourly_cost: float = _current_room_ach_total() * Global.room_ach_cost_per_ach_hour
	_set_panel_value(panel_total_cost_value, "$%.2f" % Global.room_ach_total_cost, Color(1, 0.94, 0.82, 1))
	_set_panel_value(panel_ach_rate_value, "$%.2f/hr" % Global.room_ach_cost_per_ach_hour, Color(1, 0.94, 0.82, 1))
	_set_panel_value(panel_current_hourly_cost_value, "$%.2f/hr" % current_hourly_cost, Color(1, 0.94, 0.82, 1))
	_set_panel_value(panel_exposure_avg_value, "%.0f" % float(exposure_stats["mean"]), Color(0.8, 1, 0.9, 1))
	_set_panel_value(panel_exposure_max_value, "%.0f" % float(exposure_stats["max"]), Color(1, 0.84, 0.84, 1))
	_set_panel_value(panel_exposure_total_value, "%.0f" % float(exposure_stats["total"]), Color(0.78, 0.93, 1, 1))
	var ach_control_mode_text := "🅂 Schedule or 🄼 Manual"
	if brave_mode_active:
		ach_control_mode_text = "🄱  BRAVE Mode"
	elif health_mode_active:
		ach_control_mode_text = "🄷  Health Mode"
	_set_panel_value(panel_ach_control_value, ach_control_mode_text, Color(0.87, 0.89, 1, 1))
	_update_simulation_state_card()

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

	last_run_summary_label.text = " %s (run: %s) | Alerts %d | Cost $%.2f | Exposure Avg %d" % [
		player_name,
		run_id,
		alert_count,
		total_cost,
		exposure_mean
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
	if active and brave_mode_active:
		_set_brave_mode(false)
	if health_mode_active == active:
		return

	health_mode_active = active
	var current_time_s: float = Global.current_time_s()
	for room in room_nodes:
		if is_instance_valid(room) and room.has_method("set_health_mode_enabled"):
			room.set_health_mode_enabled(health_mode_active, current_time_s, false)

	if health_mode_active:
		_apply_health_mode_ach_overrides()
	_update_room_panel(true)

func _set_brave_mode(active: bool) -> void:
	if active and health_mode_active:
		_set_health_mode(false)
	if brave_mode_active == active:
		return

	brave_mode_active = active
	var current_time_s: float = Global.current_time_s()
	for room in room_nodes:
		if is_instance_valid(room) and room.has_method("set_health_mode_enabled"):
			room.set_health_mode_enabled(brave_mode_active, current_time_s, true)

	if brave_mode_active:
		_apply_brave_mode_ach_overrides()
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

func _apply_brave_mode_ach_overrides() -> void:
	if not brave_mode_active:
		return

	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		if room.has_method("apply_brave_mode_alert"):
			var brave_alert_active_now: bool = room.viral_load >= brave_mode_threshold
			room.apply_brave_mode_alert(brave_alert_active_now, brave_mode_min_ach)

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
		person.z_index = 10
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
	var room_description_file: String = str(config_data.get("room_description_file", default_room_description_file))
	var config_run_number: int = maxi(int(config_data.get("run_number", 0)), 0)
	var config_splash_version_text: String = str(config_data.get("splash_version_text", "")).strip_edges()
	var config_room_infected_emission_per_s: float = float(config_data.get("room_infected_emission_per_s", 1.0))
	var config_room_non_vent_decay_per_s: float = float(config_data.get("room_non_vent_decay_per_s", 0.0))
	var config_health_baseline: float = float(config_data.get("health_mode_baseline_ach", config_data.get("baseline_ach", 3.0)))
	var config_health_max: float = float(config_data.get("health_mode_max_ach", config_data.get("max_ach", 7.0)))
	var config_health_min: float = float(config_data.get("health_mode_min_ach", config_data.get("minimum_ach", 0.0)))
	health_mode_min_ach = minf(config_health_min, config_health_max)
	health_mode_max_ach = maxf(config_health_min, config_health_max)
	health_mode_baseline_ach = clampf(config_health_baseline, health_mode_min_ach, health_mode_max_ach)
	splash_version_text_override = config_splash_version_text
	_update_splash_title_text()

	for rid in Global.all_rooms:
		var room = Global.all_rooms[rid]
		if not is_instance_valid(room):
			continue
		room.infected_emission_per_s = maxf(config_room_infected_emission_per_s, 0.0)
		room.non_vent_decay_per_s = maxf(config_room_non_vent_decay_per_s, 0.0)

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
	if room_description_file != "" and not room_description_file.begins_with("res://") and not room_description_file.begins_with("user://") and not room_description_file.is_absolute_path():
		room_description_file = file.get_base_dir().path_join(room_description_file)

	_clear_simulation_persons()

	create_persons(person_file)
	load_schedule(schedule_file)
	Global.person_output_file_path = person_output_file
	Global.poison_output_file_path = poison_output_file
	Global.room_output_file_path = room_output_file
	Global.exposure_output_file_path = exposure_output_file
	Global.stats_output_file_path = stats_output_file
	Global.enable_microactivities = bool(config_data.get("enable_microactivities", true))

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
	if room_description_file != "":
		load_room_description_schedule(room_description_file)
	else:
		room_description_rows.clear()

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

func _normalize_room_name_key(value: String) -> String:
	var normalized := value.strip_edges().to_lower()
	normalized = normalized.replace("\u00a0", "")
	normalized = normalized.replace("_", "")
	normalized = normalized.replace("-", "")
	normalized = normalized.replace(" ", "")
	return normalized

func load_room_description_schedule(file: String) -> void:
	room_description_rows.clear()
	if not FileAccess.file_exists(file):
		print("Room description schedule file not found: ", file)
		return

	print("Loading room description schedule from file: ", file)
	var description_file := FileAccess.open(file, FileAccess.READ)
	if description_file == null:
		print("Unable to open room description schedule file: ", file)
		return

	var parsed_data = JSON.parse_string(description_file.get_as_text())
	if not parsed_data is Dictionary:
		print("Room description schedule must be a JSON object with a 'schedule' array")
		return

	var data: Dictionary = parsed_data
	if not data.has("schedule") or not data["schedule"] is Array:
		print("Room description schedule missing 'schedule' array")
		return

	for row in data["schedule"]:
		if not row is Dictionary:
			continue
		var row_dict: Dictionary = row
		var start_time := float(row_dict.get("start_time", 0.0))
		var end_time := float(row_dict.get("end_time", start_time))
		var descriptions_raw: Dictionary = row_dict.get("descriptions", {})
		var descriptions: Dictionary = {}
		for room_key in descriptions_raw.keys():
			var normalized_key := _normalize_room_name_key(str(room_key))
			if normalized_key != "":
				descriptions[normalized_key] = str(descriptions_raw[room_key]).strip_edges()
		room_description_rows.append({
			"start_time": start_time,
			"end_time": end_time,
			"descriptions": descriptions,
		})

	print("Loaded room description rows: ", room_description_rows.size())

func _room_schedule_description(room) -> String:
	if room_description_rows.is_empty():
		return ""

	var now_s := Global.current_time_s()
	var room_keys: Array[String] = []
	room_keys.append(_normalize_room_name_key(str(room.room_id)))
	room_keys.append(_normalize_room_name_key(_short_room_name(str(room.room_id))))
	if room.has_method("display_name"):
		room_keys.append(_normalize_room_name_key(str(room.display_name())))

	for row in room_description_rows:
		var start_time := float(row.get("start_time", 0.0))
		var end_time := float(row.get("end_time", start_time))
		var in_window := now_s >= start_time and now_s < end_time
		if end_time < start_time:
			in_window = now_s >= start_time or now_s < end_time
		if not in_window:
			continue
		var descriptions: Dictionary = row.get("descriptions", {})
		for key in room_keys:
			if key != "" and descriptions.has(key):
				return str(descriptions[key])
		for desc_key in descriptions.keys():
			var normalized_desc_key := _normalize_room_name_key(str(desc_key))
			if normalized_desc_key == "":
				continue
			for key in room_keys:
				if key == "":
					continue
				if (key.length() >= 6 and normalized_desc_key.contains(key)) or (normalized_desc_key.length() >= 6 and key.contains(normalized_desc_key)):
					return str(descriptions[desc_key])

	return ""

func _init_tutorial_ui() -> void:
	tutorial_highlight_style = StyleBoxFlat.new()
	tutorial_highlight_style.bg_color = Color(0.0, 0.0, 0.0, 0.0)
	tutorial_highlight_style.border_width_left = 3
	tutorial_highlight_style.border_width_top = 3
	tutorial_highlight_style.border_width_right = 3
	tutorial_highlight_style.border_width_bottom = 3
	tutorial_highlight_style.border_color = Color(1.0, 0.9, 0.45, 1.0)
	tutorial_highlight_style.corner_radius_top_left = 10
	tutorial_highlight_style.corner_radius_top_right = 10
	tutorial_highlight_style.corner_radius_bottom_right = 10
	tutorial_highlight_style.corner_radius_bottom_left = 10

	if tutorial_highlight_frame != null:
		tutorial_highlight_frame.add_theme_stylebox_override("panel", tutorial_highlight_style)
		tutorial_highlight_frame.visible = false

	if tutorial_overlay != null:
		tutorial_overlay.visible = false

func _request_start_with_prompt(config_path: String) -> void:
	if config_path == "":
		return
	_set_splash_version_override_from_config(config_path)
	start_simulation(config_path)
	_begin_tutorial_sequence()

func _tutorial_welcome_title() -> String:
	var shown_name := Global.player_name.strip_edges()
	if shown_name == "":
		shown_name = "Anonymous"
	return "Welcome %s! \nLet's play the BRAVE Childcare Game" % shown_name

func _build_tutorial_steps() -> Array[Dictionary]:
	return [
		{
			"title": _tutorial_welcome_title(),
			"body": "This game is focused on how well you can manage the building's air handling controls to maintain a healthy environment.",
			"target": "",
			"image": "res://Art/ChildcareCenter_RoomScene_SplashScreen.png"
		},
		{
			"title": "You need to Control the room's air cleaning rate to keep the Viral Loads at bay",
			"body": "Goal: Keep viral load levels low while balancing the cost of fan-speed. The right panel is your operations hub.",
			"target": ["PanelViralLoadGauge", "PanelAchGauge"],
			"image": "res://Art/tutorial/step_025_Counters_and_Controls.png"
		},
		{
			"title": "BRAVE's biosensor can sense Pathogens",
			"body": "The biosensor can run every 45 minutes and will trigger alerts if it detects unhealthy levels of pathogens.",
			"target": ["PanelAlertCountMatrix","SensorCountdownCard"],
			"image": "res://Art/tutorial/BRAVE_biosensor.png"
		},
		{
			"title": "8 Rooms and 50 people, its a lot to manage",
			"body": "Each room card shows ACH, viral load trend, and alert status. Toggle between the rooms (⓵ & ⓸ or E & R).",
			"target": "PanelRoomCards",
			"image": "res://Art/tutorial/RoomCard.png"
		},
		{
			"title": "Air Changes per Hour (ACH) is how often the room's air gets filtered.",
			"body": "Control the Fan Speed / Air Cleaning Rate (⓶ & ⓷ or + & -) to keep the air healthy but running the fans costs money (electricity, noise, and consumes filters faster.)",
			"target": ["PanelAchDownButton","PanelAchUpButton"],
			"image": "res://Art/tutorial/ACH_controls_Filtration.png"
		},
		{
			"title": "BRAVE's goal is to automate this process",
			"body": "See an simple version of an automated healthy building environment system at work with the '🄷 Health Mode' which auto-adjusts ACH based on room conditions.",
			"target": "PanelHealthToggleButton",
			"image": "res://Art/tutorial/step_06_health_mode.png"
		},
		{
			"title": "You control the speed and can pause and feel free to look around",
			"body": "You can Pause (⏸️ or <space>) or control the speed of the simulation (shoulder buttons or S & D).  Zoom in and out(trigger button or Z & X), and pan around the childcare center (D-pad or <arrows>).  You can end the simulation anytime",
			"target": ["SensorCountdownCard","PanelSpeedDownButton", "PanelSpeedUpButton", "PanelPauseButton","EndSimulationButton"],
			"image": "res://Art/tutorial/Zoom_in_Paused.png"
		},
		{
			"title": "See how well you do vs. other players",
			"body": "After you make it through the day, see the dynamics through the day and visit the Leaderboard",
			"target": "EndSimulationButton",
			"image": "res://Art/tutorial/LeaderBoard_Cost-vs-Exposure.png"
		}
	]

func _tutorial_texture_for_path(image_path: String) -> Texture2D:
	if image_path == "":
		return null

	if tutorial_texture_cache.has(image_path):
		return tutorial_texture_cache[image_path]

	if not ResourceLoader.exists(image_path):
		return null

	var loaded := load(image_path)
	if loaded is Texture2D:
		tutorial_texture_cache[image_path] = loaded
		return loaded
	return null

func _begin_tutorial_sequence() -> void:
	tutorial_steps = _build_tutorial_steps()
	if tutorial_steps.is_empty():
		return

	tutorial_mode_active = true
	tutorial_step_idx = 0
	tutorial_resume_paused_state = Global.is_simulation_paused
	_set_pause_state(true)

	if tutorial_overlay != null:
		tutorial_overlay.visible = true

	_show_tutorial_step()

func _end_tutorial_sequence() -> void:
	tutorial_mode_active = false
	tutorial_steps.clear()
	tutorial_step_idx = 0
	if tutorial_slide_video != null:
		tutorial_slide_video.stop()
		tutorial_slide_video.stream = null
		tutorial_slide_video.visible = false
	if tutorial_highlight_frame != null:
		tutorial_highlight_frame.visible = false
	if tutorial_overlay != null:
		tutorial_overlay.visible = false
	_set_pause_state(tutorial_resume_paused_state)

func _tutorial_target_control(target_key: String) -> Control:
	match target_key:
		"RoomPanel":
			return room_panel
		"PanelViralLoadGauge":
			return panel_vl_gauge
		"PanelAchGauge":
			return panel_ach_gauge
		"PanelRoomCards":
			return panel_room_cards
		"PanelSpeedDownButton":
			return panel_speed_down_button
		"PanelSpeedUpButton":
			return panel_speed_up_button
		"PanelAchDownButton":
			return panel_ach_down_button
		"PanelAchUpButton":
			return panel_ach_up_button
		"PanelPauseButton":
			return panel_pause_button
		"PanelHealthToggleButton":
			return panel_health_toggle_button
		"EndSimulationButton":
			return end_simulation_button
		_:
			return null

func _tutorial_target_keys(step: Dictionary) -> Array[String]:
	var keys: Array[String] = []
	var target_value = step.get("target", "")
	if target_value is Array:
		for item in target_value:
			var key := str(item).strip_edges()
			if key != "":
				keys.append(key)
	else:
		var key := str(target_value).strip_edges()
		if key != "":
			keys.append(key)
	return keys

func _show_tutorial_step() -> void:
	if not tutorial_mode_active:
		return
	if tutorial_steps.is_empty():
		_end_tutorial_sequence()
		return

	tutorial_step_idx = clampi(tutorial_step_idx, 0, tutorial_steps.size() - 1)
	var step := tutorial_steps[tutorial_step_idx]

	if tutorial_step_label != null:
		tutorial_step_label.text = "Step %d of %d" % [tutorial_step_idx + 1, tutorial_steps.size()]
	if tutorial_title_label != null:
		tutorial_title_label.text = str(step.get("title", "Tutorial"))
	if tutorial_body_label != null:
		tutorial_body_label.text = str(step.get("body", ""))
	var image_path: String = str(step.get("image", "")).strip_edges()
	if tutorial_slide_video != null:
		tutorial_slide_video.stop()
		tutorial_slide_video.stream = null
		tutorial_slide_video.visible = false
	if tutorial_slide_image != null:
		var slide_texture := _tutorial_texture_for_path(image_path)
		tutorial_slide_image.texture = slide_texture
		tutorial_slide_image.visible = slide_texture != null

	if tutorial_back_button != null:
		tutorial_back_button.disabled = tutorial_step_idx == 0
	if tutorial_next_button != null:
		tutorial_next_button.text = "Done" if tutorial_step_idx == tutorial_steps.size() - 1 else "Next"

	_tutorial_update_highlight()

func _tutorial_update_highlight() -> void:
	if tutorial_highlight_frame == null:
		return
	if tutorial_steps.is_empty() or tutorial_step_idx < 0 or tutorial_step_idx >= tutorial_steps.size():
		tutorial_highlight_frame.visible = false
		return

	var step := tutorial_steps[tutorial_step_idx]
	var target_keys := _tutorial_target_keys(step)
	if target_keys.is_empty():
		tutorial_highlight_frame.visible = false
		return

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	var found_any := false

	for target_key in target_keys:
		var target := _tutorial_target_control(target_key)
		if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
			continue
		var target_rect := target.get_global_rect()
		min_pos.x = min(min_pos.x, target_rect.position.x)
		min_pos.y = min(min_pos.y, target_rect.position.y)
		max_pos.x = max(max_pos.x, target_rect.position.x + target_rect.size.x)
		max_pos.y = max(max_pos.y, target_rect.position.y + target_rect.size.y)
		found_any = true

	if not found_any:
		tutorial_highlight_frame.visible = false
		return

	var rect := Rect2(min_pos, max_pos - min_pos)
	rect.position -= Vector2.ONE * TUTORIAL_HIGHLIGHT_PADDING
	rect.size += Vector2.ONE * TUTORIAL_HIGHLIGHT_PADDING * 2.0
	tutorial_highlight_frame.global_position = rect.position
	tutorial_highlight_frame.size = rect.size
	tutorial_highlight_frame.visible = true

func _tutorial_next_step() -> void:
	if not tutorial_mode_active:
		return
	if tutorial_step_idx >= tutorial_steps.size() - 1:
		_end_tutorial_sequence()
		return
	tutorial_step_idx += 1
	_show_tutorial_step()

func _tutorial_prev_step() -> void:
	if not tutorial_mode_active:
		return
	tutorial_step_idx = max(tutorial_step_idx - 1, 0)
	_show_tutorial_step()

func _on_tutorial_next_button_pressed() -> void:
	_tutorial_next_step()

func _on_tutorial_back_button_pressed() -> void:
	_tutorial_prev_step()

func _on_tutorial_skip_button_pressed() -> void:
	_end_tutorial_sequence()

func _update_player_name_labels() -> void:
	var shown_name := Global.player_name.strip_edges()
	if shown_name == "" and player_name_input != null:
		shown_name = player_name_input.text.strip_edges()
	if shown_name == "":
		shown_name = "Anonymous"

	if panel_player_name_label != null:
		panel_player_name_label.text = "Player Name: %s" % shown_name

func _resolve_player_name_for_run() -> void:
	var name_candidate := ""
	if player_name_input != null:
		name_candidate = player_name_input.text.strip_edges()
	if name_candidate == "":
		name_candidate = Global.player_name.strip_edges()

	if name_candidate != "":
		Global.player_name = name_candidate
		if player_name_auto_label != null:
			player_name_auto_label.visible = false
		_update_player_name_labels()
		return

	if RANDOM_PLAYER_NAMES.is_empty():
		Global.player_name = "Anonymous"
		if player_name_auto_label != null:
			player_name_auto_label.text = "No name entered. Assigned: Anonymous"
			player_name_auto_label.visible = true
		_update_player_name_labels()
		return

	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var random_name := RANDOM_PLAYER_NAMES[rng.randi_range(0, RANDOM_PLAYER_NAMES.size() - 1)]
	Global.player_name = random_name
	if player_name_input != null:
		player_name_input.text = random_name
	if player_name_auto_label != null:
		player_name_auto_label.text = "No name entered. Assigned: %s" % random_name
		player_name_auto_label.visible = true
	_update_player_name_labels()

func start_simulation(file: String):
	_resolve_player_name_for_run()
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
	_set_brave_mode(false)
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
	if tutorial_mode_active:
		_end_tutorial_sequence()

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
	if player_name_input != null:
		player_name_input.text = ""
	Global.player_name = ""
	if player_name_auto_label != null:
		player_name_auto_label.visible = false
	_update_player_name_labels()
	_set_brave_mode(false)
	_set_health_mode(false)
	_refresh_last_run_summary(Global.stats_output_file_path)
	_update_room_panel(true)

func _on_save_object_button_pressed():
	object_file_dialog.show()

func _on_object_file_selected(file: String):
	object_file_dialog.hide()
	save_objects(file)

func _on_start_simulation_default_button_pressed():
	_request_start_with_prompt(default_config_path)

func _on_start_simulation_button_pressed():
	config_file_dialog.show()

func _on_config_file_selected(file: String):
	config_file_dialog.hide()
	_request_start_with_prompt(file)

func _on_player_name_input_changed(new_text: String):
	Global.player_name = new_text.strip_edges()
	if player_name_auto_label != null:
		player_name_auto_label.visible = false
	_update_player_name_labels()

func _on_end_simulation_button_pressed():
	_end_simulation("manual")

func _exposure_stats() -> Dictionary:
	if Global.all_persons.is_empty():
		return {
			"count": 0,
			"total": 0.0,
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
		"total": total,
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

func _resolved_splash_version_text() -> String:
	var splash_version := splash_version_text_override
	if splash_version == "":
		splash_version = str(ProjectSettings.get_setting("application/config/splash_version_text", "")).strip_edges()
	if splash_version == "":
		splash_version = str(ProjectSettings.get_setting("application/config/version", "")).strip_edges()
	if splash_version == "":
		return ""
	if splash_version.begins_with("v") or splash_version.begins_with("V"):
		return splash_version
	return "v %s" % splash_version

func _config_splash_version_text(config_path: String) -> String:
	if config_path == "":
		return ""
	if not FileAccess.file_exists(config_path):
		return ""
	var config_file := FileAccess.open(config_path, FileAccess.READ)
	if config_file == null:
		return ""
	var parsed_config = JSON.parse_string(config_file.get_as_text())
	if not parsed_config is Dictionary:
		return ""
	return str((parsed_config as Dictionary).get("splash_version_text", "")).strip_edges()

func _set_splash_version_override_from_config(config_path: String) -> void:
	splash_version_text_override = _config_splash_version_text(config_path)
	_update_splash_title_text()

func _update_splash_title_text() -> void:
	if title_label == null:
		return
	var base_text := "BRAVE\nChildcare Simulator"
	var version_text := _resolved_splash_version_text()
	if version_text == "":
		title_label.text = base_text
	else:
		title_label.text = "%s\n%s" % [base_text, version_text]

func _ready() -> void:
	_set_splash_version_override_from_config(default_config_path)
	object_file_dialog.file_selected.connect(_on_object_file_selected)
	config_file_dialog.file_selected.connect(_on_config_file_selected)

	save_object_button.pressed.connect(_on_save_object_button_pressed)
	start_simulation_button.pressed.connect(_on_start_simulation_button_pressed)
	start_simulation_default_button.pressed.connect(_on_start_simulation_default_button_pressed)
	tutorial_next_button.pressed.connect(_on_tutorial_next_button_pressed)
	tutorial_back_button.pressed.connect(_on_tutorial_back_button_pressed)
	tutorial_skip_button.pressed.connect(_on_tutorial_skip_button_pressed)
	end_simulation_button.pressed.connect(_on_end_simulation_button_pressed)
	player_name_input.text_changed.connect(_on_player_name_input_changed)
	_update_player_name_labels()
	_refresh_last_run_summary()
	_init_tutorial_ui()

	var home_dir = OS.get_environment("HOME")
	object_file_dialog.root_subfolder = home_dir
	config_file_dialog.root_subfolder = home_dir

	save_timer.timeout.connect(_on_save_timer_timeout)
	save_timer.wait_time = Global.save_every_s
	get_viewport().size_changed.connect(_update_room_panel_layout)
	_init_room_panel_widgets()
	if panel_prev_room_button != null:
		panel_prev_room_button.pressed.connect(_on_panel_prev_room_pressed)
	if panel_next_room_button != null:
		panel_next_room_button.pressed.connect(_on_panel_next_room_pressed)
	if panel_ach_down_button != null:
		panel_ach_down_button.pressed.connect(_on_panel_ach_down_pressed)
	if panel_ach_up_button != null:
		panel_ach_up_button.pressed.connect(_on_panel_ach_up_pressed)
	if panel_health_toggle_button != null:
		panel_health_toggle_button.pressed.connect(_on_panel_health_toggle_pressed)
	if panel_speed_down_button != null:
		panel_speed_down_button.pressed.connect(_on_panel_speed_down_pressed)
	if panel_speed_up_button != null:
		panel_speed_up_button.pressed.connect(_on_panel_speed_up_pressed)
	if panel_pause_button != null:
		panel_pause_button.pressed.connect(_on_panel_pause_pressed)
	_refresh_panel_controls_state()

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
	if tutorial_mode_active:
		if event.is_action_pressed("tutorial_next") and not event.is_echo():
			_tutorial_next_step()
		elif event.is_action_pressed("tutorial_prev") and not event.is_echo():
			_tutorial_prev_step()
		elif event.is_action_pressed("tutorial_exit") and not event.is_echo():
			_end_tutorial_sequence()
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("room_next") and not event.is_echo():
		_cycle_selected_room(1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("room_prev") and not event.is_echo():
		_cycle_selected_room(-1)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("room_ach_down") and not event.is_echo():
		_adjust_selected_room_ach(-ROOM_ACH_STEP)
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("room_ach_up") and not event.is_echo():
		_adjust_selected_room_ach(ROOM_ACH_STEP)
		get_viewport().set_input_as_handled()
		return

	if Global.is_simulation_active and event.is_action_pressed("speed_up") and not event.is_echo():
		_adjust_sim_speed_scale(_sim_speed_step_size())
		get_viewport().set_input_as_handled()
		return

	if Global.is_simulation_active and event.is_action_pressed("slow_down") and not event.is_echo():
		_adjust_sim_speed_scale(-_sim_speed_step_size())
		get_viewport().set_input_as_handled()
		return

	if Global.is_simulation_active and event.is_action_pressed("health_toggle") and not event.is_echo():
		_set_health_mode(not health_mode_active)
		get_viewport().set_input_as_handled()
		return

	if Global.is_simulation_active and event.is_action_pressed("brave_toggle") and not event.is_echo():
		_set_brave_mode(not brave_mode_active)
		get_viewport().set_input_as_handled()
		return

	if not Global.is_simulation_active and title_screen != null and title_screen.visible and event.is_action_pressed("start_simulation") and not event.is_echo():
		_on_start_simulation_default_button_pressed()
		get_viewport().set_input_as_handled()
		return

	if not Global.is_simulation_active:
		return

	if event.is_action_pressed("pause") and not event.is_echo():
		_toggle_pause()
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
	if brave_mode_active:
		return "🄱"
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
	if not should_evaluate:
		var last_eval := float(room_alert_last_eval_s.get(room_id, -INF))
		if room_alert_check_interval_s <= 0.0 or now_s - last_eval >= room_alert_check_interval_s:
			should_evaluate = true

	if should_evaluate:
		var new_state: bool = room.viral_load >= room_alert_threshold_vl
		room_alert_active[room_id] = new_state
		if new_state:
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

func _next_sensor_reading_counter_value() -> int:
	if room_alert_check_interval_s <= 0.0:
		return 0
	if room_nodes.is_empty():
		return 0

	var now_s: float = Global.current_time_s()
	var next_due: float = INF
	for room in room_nodes:
		var room_id: String = room.room_id
		var last_eval: float = float(room_alert_last_eval_s.get(room_id, now_s))
		var candidate: float = last_eval + room_alert_check_interval_s
		next_due = min(next_due, candidate)

	if next_due == INF:
		return 0
	var remaining_minutes: int = int(ceili(max(0.0, next_due - now_s) / 60.0))
	return clampi(remaining_minutes, 0, 99)

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
		room_panel_text.text = "[b]Panel Notes[/b]\nRun the sim to enable controls and room cards."
		_ensure_room_card_count(0)
		_update_room_panel_widgets(null, false)
		_refresh_panel_controls_state()
		return

	var selected_room = null
	var selected_alert := false

	for idx in range(room_nodes.size()):
		var room = room_nodes[idx]
		var _alert_light := _room_alert_light(room)
		if idx == selected_room_idx:
			selected_room = room
			selected_alert = bool(room_alert_active.get(room.room_id, false))

	_update_room_cards(selected_room)
	room_panel_text.text = "[b]Panel Notes[/b]\nKeyboard shortcuts still work: R/E, +/- , H, S, D."
	_update_room_panel_widgets(selected_room, selected_alert)
	_refresh_panel_controls_state()


func _process(_delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size != last_viewport_size:
		_update_room_panel_layout()
	if tutorial_mode_active:
		_tutorial_update_highlight()

	if not tutorial_mode_active and Input.is_action_pressed("camera_right"):
		camera_2d.offset.x += 32
	if not tutorial_mode_active and Input.is_action_pressed("camera_left"):
		camera_2d.offset.x -= 32
	if not tutorial_mode_active and Input.is_action_pressed("camera_down"):
		camera_2d.offset.y += 32
	if not tutorial_mode_active and Input.is_action_pressed("camera_up"):
		camera_2d.offset.y -= 32
	if not tutorial_mode_active and Input.is_action_pressed("zoom_in"):
		camera_2d.zoom.x *= 1.05
		camera_2d.zoom.y *= 1.05
	if not tutorial_mode_active and Input.is_action_pressed("zoom_out"):
		camera_2d.zoom.x *= 0.95
		camera_2d.zoom.y *= 0.95

	_update_alert_lamp_visual(Global.current_time_s())
	#if Input.is_action_pressed("pause"):
		#get_tree().paused = true
	#if Input.is_action_pressed("unpause"):
		#get_tree().paused = false

	_update_room_panel()

	if Global.current_time_s() > Global.runtime_end_s:
		_end_simulation("schedule_complete")

func _physics_process(_delta: float) -> void:
	if Global.can_advance_simulation() and Global.sim_clock_s > 0.0:
		Global.sim_clock_s += Global.seconds_per_physics_tick
		if brave_mode_active:
			_apply_brave_mode_ach_overrides()
		else:
			_apply_health_mode_ach_overrides()
		_update_room_cost()

		if Global.sim_clock_s - Global.prev_abs_event_s > Global.abs_tick_duration_s:
			for pid in Global.all_persons:
				Global.all_persons[pid].do_absorption()
			Global.prev_abs_event_s = Global.sim_clock_s
