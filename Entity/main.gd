extends Node

@onready var object_file_dialog: FileDialog = %ObjectFileDialog
@onready var config_file_dialog: FileDialog = %ConfigFileDialog

@onready var save_object_button: Button = %SaveObjectButton
@onready var start_simulation_button: Button = %StartSimulationButton
@onready var start_simulation_default_button: Button = %StartSimulationDefaultButton
@onready var start_autoplay_button: Button = %StartAutoplayButton
@onready var title_label: Label = $TitleScreen/TitleLabel
@onready var version_label: Label = %VersionLabel
@onready var level_button: Button = %LevelButton
@onready var level_label_large: Label = %LevelLabel2
@onready var title_screen_vbox: VBoxContainer = $TitleScreen/VBoxContainer
@onready var player_name_input: LineEdit = %PlayerNameInput
@onready var player_name_auto_label: Label = %PlayerNameAutoLabel
@onready var title_summary_gap: Control = $TitleScreen/VBoxContainer/PrimarySummaryGap

@onready var title_screen: CanvasLayer = %TitleScreen
@onready var map: Node2D = %Map
@onready var camera_2d: Camera2D = %Camera2D
@onready var end_simulation_button: Button = %EndSimulationButton
@onready var last_run_summary_label: Label = %LastRunSummaryLabel
@onready var title_exposure_chart: Control = %TitleExposureChart
@onready var title_exposure_chart_status: Label = %TitleExposureChartStatus
@onready var title_cost_chart: Control = %TitleCostChart
@onready var title_cost_chart_status: Label = %TitleCostChartStatus
@onready var title_alert_chart: Control = %TitleAlertChart
@onready var title_alert_chart_status: Label = %TitleAlertChartStatus
@onready var game_over_layer: CanvasLayer = %GameOverLayer
@onready var pause_overlay: Control = %PauseOverlay
@onready var game_controls_overlay: Control = %GameControlsOverlay
@onready var game_controls_size_rect: Control = %GameControlsOverlay/Sizing/SizeRect
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
@onready var panel_brave_toggle_button: Button = %PanelBraveToggleButton
@onready var panel_autoplay_toggle_button: Button = %PanelAutoplayToggleButton
@onready var panel_game_controls_button: Button = %PanelGameControlsButton
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
@onready var tutorial_card: PanelContainer = %TutorialCard
@onready var tutorial_card_margin: MarginContainer = %TutorialCardMargin
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
@export var splash_version_label_value: String = "3.3"
@export var difficulty_level_map: Dictionary = {"Easy": "easy", "Standard": "standard", "Hard": "hard"}
@export var current_difficulty_level: String = "Standard"
@export var default_room_description_file: String = "res://inputs/schedule_rooms.json"
@export var room_alert_threshold_vl: float = 600.0
@export var room_alert_check_interval_s: float = 45.0 * 60.0
@export var use_raw_alert_counts_for_ui: bool = true
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
@export var title_screen_title_font_size_min: int = 60
@export var title_screen_title_font_size_max: int = 150
@export var title_screen_title_top_fraction: float = 0.02
@export var title_screen_content_top_fraction: float = 0.40
@export var title_screen_content_height_fraction: float = 0.45
@export var title_screen_summary_gap_fraction: float = 0.15
@export var comparison_curated_run_ids: PackedStringArray = ["id-0115", "id-0110"]
@export var level_chart_refresh_delay_s: float = 0.3
@export var panel_vl_gauge_max: float = 1000.0
@export var panel_ach_gauge_max: float = 9.0
@export var panel_alert_lamp_pulse_hz: float = 1.6
@export var autoplay_camera_tween_duration_s: float = 0.45
@export var autoplay_focus_padding_fraction: float = 0.10
@export var autoplay_focus_right_padding_fraction: float = 0.30
@export var autoplay_focus_zoom_min: float = 0.12
@export var autoplay_focus_zoom_max: float = 2.6
@export var tutorial_card_offset_left_tutorial: float = 0.12 # 8% from left
@export var tutorial_card_offset_right_tutorial: float = -0.12 # -8% from right
@export var tutorial_card_offset_top_tutorial: float = 0.4 # 12% from top
@export var tutorial_card_offset_bottom_tutorial: float = -0.03 # -3% from bottom
@export var tutorial_card_margin_tutorial: int = 18
@export var tutorial_step_font_size_tutorial: int = 36
@export var tutorial_title_font_size_tutorial: int = 60
@export var tutorial_body_font_size_tutorial: int = 42
@export var tutorial_image_min_height_tutorial: float = 550.0
@export var autoplay_card_offset_left: float = 0.08 # 8% from left
@export var autoplay_card_offset_right: float = -0.25 
@export var autoplay_card_offset_top: float = 0.8
@export var autoplay_card_offset_bottom: float = -0.03 # -3% from bottom
@export var autoplay_card_margin: int = 12
@export var autoplay_step_font_size: int = 24
@export var autoplay_title_font_size: int = 42
@export var autoplay_body_font_size: int = 28
@export var autoplay_image_min_height: float = 260.0
@export var autoplay_show_step_label: bool = false
@export var autoplay_include_status_note: bool = false
@export var autoplay_body_max_chars: int = 220
@export var overlay_card_bottom_priority_layout_enabled: bool = true
@export var overlay_card_safe_top_fraction: float = 0.02

var room_nodes: Array = []
var selected_room_idx: int = -1
var room_vl_last: Dictionary = {}
var room_alert_last_eval_s: Dictionary = {}
var room_alert_active: Dictionary = {}
var room_alert_trigger_count_total: int = 0
var room_alert_trigger_count_by_room: Dictionary = {}
var room_alert_raw_count_total: int = 0
var room_alert_raw_count_by_room: Dictionary = {}
var room_cost_last_update_s: float = 0.0
var room_panel_next_update_s: float = 0.0
var last_viewport_size: Vector2 = Vector2.ZERO
var health_mode_active: bool = false
var brave_mode_active: bool = false
var health_mode_baseline_ach: float = 3.0
var health_mode_max_ach: float = 9.0
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
var game_controls_overlay_active: bool = false
var game_controls_resume_paused_state: bool = false
var tutorial_steps: Array[Dictionary] = []
var tutorial_step_idx: int = 0
var tutorial_highlight_style: StyleBoxFlat
var tutorial_texture_cache: Dictionary = {}
var autoplay_mode_active: bool = false
var autoplay_cards_pool: Array[Dictionary] = []
var autoplay_seen_ids: Dictionary = {}
var autoplay_completed_ids: Dictionary = {}
var autoplay_show_counts: Dictionary = {}
var autoplay_last_shown_s: Dictionary = {}
var autoplay_interrupted_cooldown_until: Dictionary = {}
var autoplay_current_card: Dictionary = {}
var autoplay_current_actions: Array[Dictionary] = []
var autoplay_current_action_idx: int = 0
var autoplay_current_context: Dictionary = {}
var autoplay_card_started_s: float = 0.0
var autoplay_card_started_wall_s: float = 0.0
var autoplay_wait_until_s: float = 0.0
var autoplay_post_delay_until_s: float = 0.0
var autoplay_overlay_note: String = ""
var autoplay_rng: RandomNumberGenerator = RandomNumberGenerator.new()
var autoplay_camera_focus_tween: Tween
var level_baseline_run_ids_by_level: Dictionary = {}
var recent_run_ids_by_level: Dictionary = {}
var last_run_summary_by_level: Dictionary = {}
var run_player_name_by_id: Dictionary = {}
var title_chart_payload_by_level: Dictionary = {}
var level_chart_refresh_token: int = 0
@export var health_mode_alert_hold_minutes: float = 5.0 # Minutes to hold max ACH after alert in health mode

const ROOM_ACH_STEP: float = 1.0
const ROOM_VL_TREND_EPSILON: float = 0.01
const ROOM_COST_UPDATE_INTERVAL_S: float = 60.0
const GAME_CONTROLS_OVERLAY_WIDTH_FRACTION: float = 0.60
const GAME_CONTROLS_OVERLAY_HEIGHT_FRACTION: float = 0.90
const TUTORIAL_HIGHLIGHT_PADDING: float = 12.0
const AUTOPLAY_INTERRUPT_COOLDOWN_S: float = 30.0
const AUTOPLAY_DEFAULT_INTERRUPT_THRESHOLD: int = 100
const AUTOPLAY_DEFAULT_MAX_SHOW_S: float = 24.0
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
const TITLE_CHART_SERIES_TARGET: int = 5
const TITLE_CHART_PLACEHOLDER_START_S: float = 7.0 * 3600.0
const TITLE_CHART_PLACEHOLDER_END_S: float = 18.0 * 3600.0
const EXPOSURE_CHART_COLORS: Array[Color] = [
	Color("#7ec8ff"),
	Color("#ffab6f"),
	Color("#9ee493"),
	Color("#d9a0e8"),
	Color("#f7d96b"),
]

func _run_id_number(run_id: String) -> int:
	var parts: PackedStringArray = run_id.split("-")
	if parts.size() != 2:
		return -1
	return int(parts[1])

func _sort_run_ids_desc(a: String, b: String) -> bool:
	return _run_id_number(a) > _run_id_number(b)

func _normalize_run_id(raw_value: String) -> String:
	var text: String = raw_value.strip_edges().to_lower()
	if text == "":
		return ""
	if text.begins_with("id-"):
		return "id-%04d" % int(text.trim_prefix("id-"))
	return "id-%04d" % int(text)

func _normalized_level_name(raw_level: String) -> String:
	var normalized_input: String = raw_level.strip_edges().to_lower()
	if normalized_input == "":
		return ""
	for level_key_variant in difficulty_level_map.keys():
		var level_key: String = str(level_key_variant)
		if level_key.to_lower() == normalized_input:
			return level_key
		var level_suffix: String = str(difficulty_level_map[level_key_variant]).strip_edges().to_lower()
		if level_suffix != "" and level_suffix == normalized_input:
			return level_key
	return ""

func _parse_run_id_list(raw_ids: Variant, max_count: int = 2) -> PackedStringArray:
	var ids: Array[String] = []
	if raw_ids is PackedStringArray:
		for run_id_raw in (raw_ids as PackedStringArray):
			var run_id: String = _normalize_run_id(str(run_id_raw))
			if run_id == "" or ids.has(run_id):
				continue
			ids.append(run_id)
			if max_count > 0 and ids.size() >= max_count:
				break
	elif raw_ids is Array:
		for run_id_raw in (raw_ids as Array):
			var run_id: String = _normalize_run_id(str(run_id_raw))
			if run_id == "" or ids.has(run_id):
				continue
			ids.append(run_id)
			if max_count > 0 and ids.size() >= max_count:
				break
	return PackedStringArray(ids)

func _read_config_data(config_path: String) -> Dictionary:
	if config_path == "":
		return {}
	if not FileAccess.file_exists(config_path):
		return {}
	var config_file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if config_file == null:
		return {}
	var parsed_config = JSON.parse_string(config_file.get_as_text())
	if not (parsed_config is Dictionary):
		return {}
	return parsed_config

func _resolve_stats_output_path_for_level(level: String) -> String:
	var normalized_level: String = _normalized_level_name(level)
	if normalized_level == "":
		normalized_level = "Standard"
	var config_path: String = _get_config_path_for_level(normalized_level)
	var stats_path: String = _resolve_stats_output_path_from_config(config_path)
	if stats_path != "":
		return stats_path
	return _resolve_stats_output_path_from_config(default_config_path)

func _refresh_level_baseline_cache() -> void:
	level_baseline_run_ids_by_level.clear()
	for level_key_variant in difficulty_level_map.keys():
		var level_key: String = str(level_key_variant)
		var config_path: String = _get_config_path_for_level(level_key)
		var config_data: Dictionary = _read_config_data(config_path)
		var baseline_ids: PackedStringArray = _parse_run_id_list(config_data.get("comparison_baseline_run_ids", comparison_curated_run_ids), 4)
		if baseline_ids.is_empty():
			baseline_ids = _parse_run_id_list(comparison_curated_run_ids, 2)
		level_baseline_run_ids_by_level[level_key] = baseline_ids

func _refresh_run_history_by_level(stats_file_path: String = "") -> void:
	recent_run_ids_by_level.clear()
	last_run_summary_by_level.clear()
	run_player_name_by_id.clear()
	for level_key_variant in difficulty_level_map.keys():
		recent_run_ids_by_level[str(level_key_variant)] = []

	var effective_stats_path: String = stats_file_path
	if effective_stats_path == "":
		effective_stats_path = _resolve_stats_output_path_for_level(current_difficulty_level)
	if effective_stats_path == "":
		return
	if not FileAccess.file_exists(effective_stats_path):
		return

	var stats_file: FileAccess = FileAccess.open(effective_stats_path, FileAccess.READ)
	if stats_file == null:
		return

	var lines: PackedStringArray = stats_file.get_as_text().split("\n", false)
	for idx in range(lines.size() - 1, -1, -1):
		var line: String = lines[idx].strip_edges()
		if line == "":
			continue
		var parsed: Variant = JSON.parse_string(line)
		if not (parsed is Dictionary):
			continue
		var row: Dictionary = parsed
		if str(row.get("event", "")) != "run_summary":
			continue
		var level_name: String = _normalized_level_name(str(row.get("level", "")))
		if level_name == "":
			continue
		var run_id: String = _normalize_run_id(str(row.get("run_id", "")))
		if run_id == "":
			continue
		if not run_player_name_by_id.has(run_id):
			var row_player_name: String = str(row.get("player_name", "")).strip_edges()
			if row_player_name == "":
				row_player_name = "Anonymous"
			run_player_name_by_id[run_id] = row_player_name

		var recent_ids: Array = recent_run_ids_by_level.get(level_name, [])
		if not recent_ids.has(run_id):
			recent_ids.append(run_id)
			recent_run_ids_by_level[level_name] = recent_ids
		if not last_run_summary_by_level.has(level_name):
			last_run_summary_by_level[level_name] = row

func _outputs_dir_path() -> String:
	var project_outputs: String = ProjectSettings.globalize_path("res://outputs")
	if DirAccess.dir_exists_absolute(project_outputs):
		return project_outputs

	if active_config_path != "":
		var active_outputs: String = active_config_path.get_base_dir().path_join("outputs")
		if DirAccess.dir_exists_absolute(active_outputs):
			return active_outputs

	var default_config_abs: String = ProjectSettings.globalize_path(default_config_path)
	var default_outputs: String = default_config_abs.get_base_dir().get_base_dir().path_join("outputs")
	if DirAccess.dir_exists_absolute(default_outputs):
		return default_outputs

	return project_outputs

func _list_available_exposure_run_ids() -> PackedStringArray:
	var outputs_dir: String = _outputs_dir_path()
	var dir: DirAccess = DirAccess.open(outputs_dir)
	if dir == null:
		return PackedStringArray()

	var run_ids: Array[String] = []
	var run_id_regex: RegEx = RegEx.new()
	run_id_regex.compile("^output_childcare_people_movement_exposure_(id-\\d{4})\\.json$")

	dir.list_dir_begin()
	while true:
		var file_name: String = dir.get_next()
		if file_name == "":
			break
		if dir.current_is_dir():
			continue
		var match: RegExMatch = run_id_regex.search(file_name)
		if match != null:
			run_ids.append(match.get_string(1))
	dir.list_dir_end()

	run_ids.sort_custom(Callable(self, "_sort_run_ids_desc"))
	return PackedStringArray(run_ids)

func _selected_exposure_run_ids() -> PackedStringArray:
	return _selected_exposure_run_ids_for_level(current_difficulty_level)

func _selected_exposure_run_ids_for_level(level_name: String) -> PackedStringArray:
	var selected_level: String = _normalized_level_name(level_name)
	if selected_level == "":
		selected_level = "Standard"
	var available: PackedStringArray = _list_available_exposure_run_ids()
	var selected: Array[String] = []
	var level_recent_ids: PackedStringArray = PackedStringArray(recent_run_ids_by_level.get(selected_level, []))
	var baseline_ids: PackedStringArray = PackedStringArray(level_baseline_run_ids_by_level.get(selected_level, PackedStringArray()))

	# Slot 0: Latest is always the most recent run for this level.
	var latest_run_id: String = ""
	if level_recent_ids.size() > 0:
		latest_run_id = level_recent_ids[0]
	if latest_run_id != "":
		selected.append(latest_run_id)

	# Slots 1-4: configured baselines in order.
	for run_id in baseline_ids:
		if run_id == "" or selected.has(run_id):
			continue
		selected.append(run_id)
		if selected.size() >= TITLE_CHART_SERIES_TARGET:
			break

	# Fill remaining slots from level recent runs, then any available exposure file.
	for run_id in level_recent_ids:
		if selected.size() >= TITLE_CHART_SERIES_TARGET:
			break
		if run_id == "" or selected.has(run_id):
			continue
		selected.append(run_id)

	for run_id in available:
		if selected.size() >= TITLE_CHART_SERIES_TARGET:
			break
		if run_id == "" or selected.has(run_id):
			continue
		selected.append(run_id)

	return PackedStringArray(selected)

func _zero_series_placeholder() -> Array[Dictionary]:
	return [
		{"time": TITLE_CHART_PLACEHOLDER_START_S, "value": 0.0},
		{"time": TITLE_CHART_PLACEHOLDER_END_S, "value": 0.0},
	]

func _load_chart_points_for_run(chart_type: String, run_id: String) -> Array[Dictionary]:
	if chart_type == "cost":
		return _load_total_cost_series(run_id)
	if chart_type == "alerts":
		return _load_cumulative_alert_series(run_id)
	return _load_total_exposure_series(run_id)

func _build_cached_chart_payload_for_level(level_name: String, chart_type: String, run_ids: PackedStringArray) -> Dictionary:
	var series: Array[Dictionary] = []
	var missing_run_ids: Array[String] = []

	for idx in range(run_ids.size()):
		var run_id: String = run_ids[idx]
		var points: Array[Dictionary] = _load_chart_points_for_run(chart_type, run_id)
		if points.is_empty():
			missing_run_ids.append(run_id)
			points = _zero_series_placeholder()
		var color_idx: int = idx % EXPOSURE_CHART_COLORS.size()
		series.append({
			"label": _run_chart_label(idx, run_id),
			"color": EXPOSURE_CHART_COLORS[color_idx],
			"is_latest": idx == 0,
			"points": points,
		})

	var status_text: String = "Comparing latest run with curated runs."
	if not missing_run_ids.is_empty():
		status_text = "No %s data for runs: %s (plotted as zero)." % [chart_type, ", ".join(missing_run_ids)]

	return {
		"series": series,
		"status": status_text,
	}

func _preload_title_chart_payloads(stats_file_path: String = "") -> void:
	title_chart_payload_by_level.clear()
	_refresh_level_baseline_cache()

	var effective_stats_path: String = stats_file_path
	if effective_stats_path == "":
		effective_stats_path = _resolve_stats_output_path_for_level(current_difficulty_level)
	_refresh_run_history_by_level(effective_stats_path)

	for level_key_variant in difficulty_level_map.keys():
		var level_name: String = str(level_key_variant)
		var run_ids: PackedStringArray = _selected_exposure_run_ids_for_level(level_name)
		title_chart_payload_by_level[level_name] = {
			"exposure": _build_cached_chart_payload_for_level(level_name, "exposure", run_ids),
			"cost": _build_cached_chart_payload_for_level(level_name, "cost", run_ids),
			"alerts": _build_cached_chart_payload_for_level(level_name, "alerts", run_ids),
		}

func _title_chart_payload(chart_type: String) -> Dictionary:
	var selected_level: String = _normalized_level_name(current_difficulty_level)
	if selected_level == "":
		selected_level = "Standard"
	var level_payloads: Dictionary = title_chart_payload_by_level.get(selected_level, {})
	var payload: Dictionary = level_payloads.get(chart_type, {})
	if not payload.is_empty():
		return payload
	return _build_comparison_chart_payload(chart_type)

func _selected_alert_run_ids() -> PackedStringArray:
	var available: PackedStringArray = _selected_exposure_run_ids()
	var selected: Array[String] = []

	# Prefer most recent runs that actually contain alert events.
	for run_id in available:
		if _load_cumulative_alert_series(run_id).is_empty():
			continue
		selected.append(run_id)
		if selected.size() >= 5:
			break

	if selected.is_empty():
		# Fallback so status text can still report missing alert history on known runs.
		return _selected_exposure_run_ids()

	return PackedStringArray(selected)

func _run_display_details(run_id: String) -> String:
	var player_name: String = str(run_player_name_by_id.get(run_id, "")).strip_edges()
	if player_name == "":
		player_name = "Anonymous"
	return "%s (%s)" % [player_name, run_id]

func _run_chart_label(idx: int, run_id: String) -> String:
	var details: String = _run_display_details(run_id)
	if idx == 0:
		return "Latest: %s" % details
	if idx == 1:
		return "A: %s" % details
	if idx == 2:
		return "B: %s" % details
	if idx == 3:
		return "C: %s" % details
	if idx == 4:
		return "D: %s" % details
	return "Run %d: %s" % [idx + 1, details]

func _load_total_exposure_series(run_id: String) -> Array[Dictionary]:
	var file_path: String = _outputs_dir_path().path_join("output_childcare_people_movement_exposure_%s.json" % run_id)
	if not FileAccess.file_exists(file_path):
		return []

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return []

	var totals_by_time: Dictionary = {}
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line == "":
			continue
		var parsed = JSON.parse_string(line)
		if not (parsed is Dictionary):
			continue
		var row: Dictionary = parsed
		if str(row.get("event", "")) != "person_exposure":
			continue

		var time_value: float = float(row.get("time", -1.0))
		if time_value < 0.0:
			continue
		var exposure_value: float = float(row.get("cumulative_viral_exposure", 0.0))
		var total: float = float(totals_by_time.get(time_value, 0.0)) + exposure_value
		totals_by_time[time_value] = total

	var times: Array = totals_by_time.keys()
	times.sort()
	var points: Array[Dictionary] = []
	for time_key in times:
		points.append({
			"time": float(time_key),
			"value": float(totals_by_time[time_key]),
		})
	return points

func _load_total_cost_series(run_id: String) -> Array[Dictionary]:
	var file_path: String = _outputs_dir_path().path_join("output_childcare_rooms_%s.json" % run_id)
	if not FileAccess.file_exists(file_path):
		return []

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return []

	var cost_by_time: Dictionary = {}
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line == "":
			continue
		var parsed: Variant = JSON.parse_string(line)
		if not (parsed is Dictionary):
			continue
		var row: Dictionary = parsed
		if str(row.get("event", "")) != "room_state":
			continue

		var time_value: float = float(row.get("time", -1.0))
		if time_value < 0.0:
			continue
		if cost_by_time.has(time_value):
			continue
		cost_by_time[time_value] = float(row.get("ach_total_cost", 0.0))

	var times: Array = cost_by_time.keys()
	times.sort()
	var points: Array[Dictionary] = []
	for time_key in times:
		points.append({
			"time": float(time_key),
			"value": float(cost_by_time[time_key]),
		})
	return points

func _load_cumulative_alert_series(run_id: String) -> Array[Dictionary]:
	var file_path: String = _outputs_dir_path().path_join("output_childcare_rooms_%s.json" % run_id)
	if not FileAccess.file_exists(file_path):
		return []

	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return []

	var raw_points: Array[Dictionary] = []
	var alert_times: Array[float] = []
	while not file.eof_reached():
		var line: String = file.get_line().strip_edges()
		if line == "":
			continue
		var parsed: Variant = JSON.parse_string(line)
		if not (parsed is Dictionary):
			continue
		var row: Dictionary = parsed
		var event_name: String = str(row.get("event", ""))

		var time_value: float = float(row.get("time", -1.0))
		if time_value < 0.0:
			continue

		if event_name == "room_alert_raw":
			var raw_value: int = int(row.get("raw_alert_count", -1))
			if raw_value >= 0:
				raw_points.append({
					"time": time_value,
					"value": raw_value,
				})
			continue

		if event_name == "room_alert":
			alert_times.append(time_value)
			if use_raw_alert_counts_for_ui and row.has("raw_alert_count"):
				raw_points.append({
					"time": time_value,
					"value": int(row.get("raw_alert_count", 0)),
				})

	if use_raw_alert_counts_for_ui and not raw_points.is_empty():
		return raw_points

	alert_times.sort()
	var points: Array[Dictionary] = []
	var cumulative_count: int = 0
	for alert_time in alert_times:
		cumulative_count += 1
		points.append({
			"time": alert_time,
			"value": cumulative_count,
		})
	return points

func _refresh_title_exposure_chart() -> void:
	if title_exposure_chart == null:
		return

	var payload: Dictionary = _title_chart_payload("exposure")
	var series: Array[Dictionary] = payload.get("series", [])
	var status_text: String = str(payload.get("status", ""))

	if title_exposure_chart.has_method("set_series"):
		title_exposure_chart.call("set_series", series, "")

	if title_exposure_chart_status != null:
		title_exposure_chart_status.text = status_text

func _refresh_title_cost_chart() -> void:
	if title_cost_chart == null:
		return

	var payload: Dictionary = _title_chart_payload("cost")
	var series: Array[Dictionary] = payload.get("series", [])
	var status_text: String = str(payload.get("status", ""))

	if title_cost_chart.has_method("set_series"):
		title_cost_chart.call("set_series", series, "")

	if title_cost_chart_status != null:
		title_cost_chart_status.text = status_text

func _refresh_title_alert_chart() -> void:
	if title_alert_chart == null:
		return

	var payload: Dictionary = _title_chart_payload("alerts")
	var series: Array[Dictionary] = payload.get("series", [])
	var status_text: String = str(payload.get("status", ""))

	if title_alert_chart.has_method("set_series"):
		title_alert_chart.call("set_series", series, "")

	if title_alert_chart_status != null:
		title_alert_chart_status.text = status_text

func _build_comparison_chart_payload(chart_type: String) -> Dictionary:
	var run_ids: PackedStringArray = _selected_exposure_run_ids()
	if chart_type == "alerts":
		run_ids = _selected_alert_run_ids()
	var series: Array[Dictionary] = []
	var missing_run_ids: Array[String] = []

	for idx in range(run_ids.size()):
		var run_id: String = run_ids[idx]
		var points: Array[Dictionary] = []
		if chart_type == "cost":
			points = _load_total_cost_series(run_id)
		elif chart_type == "alerts":
			points = _load_cumulative_alert_series(run_id)
		else:
			points = _load_total_exposure_series(run_id)
		if points.is_empty():
			missing_run_ids.append(run_id)
			continue
		var color_idx: int = idx % EXPOSURE_CHART_COLORS.size()
		series.append({
			"label": _run_chart_label(idx, run_id),
			"color": EXPOSURE_CHART_COLORS[color_idx],
			"is_latest": idx == 0,
			"points": points,
		})

	var empty_message := "Exposure chart: no valid run files found in outputs/."
	if chart_type == "cost":
		empty_message = "Cost chart: no valid room run files found in outputs/."
	elif chart_type == "alerts":
		empty_message = "Alert chart: no room alert events found in outputs/."
	var status_text := ""
	if series.is_empty():
		status_text = empty_message
	elif missing_run_ids.is_empty():
		status_text = "Comparing latest run with curated runs."
	else:
		status_text = "Missing run files: %s" % ", ".join(missing_run_ids)

	return {
		"series": series,
		"status": status_text,
	}

func _achievement_for_row(row: Dictionary) -> Dictionary:
	var alert_count: int = _alert_count_for_row(row, 9999)
	var avg_exposure: float = float(row.get("exposure_mean_cumulative", INF))
	var total_cost: float = float(row.get("ach_total_cost", INF))
	var random_roll: float = randf()

	if random_roll < 0.2:
		return {
			"medal": "Bioareosol Buster",
			"color": Color("#f5c542"),
		}
	if random_roll < 0.40:
		return {
			"medal": "HVAC Hero",
			"color": Color("#d5dee9"),
		}
	if random_roll < 0.6:
		return {
			"medal": "Aerosol Avenger",
			"color": Color("#d18c52"),
		}
	if random_roll < 0.8:
		return {
			"medal": "Clean Air Crafter",
			"color": Color("#559bae")
		}
	return  {
		"medal": "BRAVE Backer",
		"color": Color("#7bd7e7"),
	}

func _game_over_summary_text(row: Dictionary) -> String:
	if row.is_empty():
		return "No run summary was recorded for this simulation."

	var run_id: String = str(row.get("run_id", "n/a"))
	var alerts: int = _alert_count_for_row(row)
	var alert_label: String = _alert_count_label_text()
	var total_cost: float = float(row.get("ach_total_cost", 0.0))
	var avg_exposure: float = float(row.get("exposure_mean_cumulative", 0.0))
	var max_exposure: float = float(row.get("exposure_max_cumulative", 0.0))
	return "Run %s | %s %d | Cost $%.2f | Avg Exposure %.0f | Max Exposure %.0f" % [
		run_id,
		alert_label,
		alerts,
		total_cost,
		avg_exposure,
		max_exposure,
	]

func _show_game_over(reason: String) -> void:
	if game_over_layer == null:
		_return_to_title_from_run()
		return

	# Fetch the most complete run for consistency with Last Run Summary
	var run_row: Dictionary = _read_last_run_summary_row(Global.stats_output_file_path)
	if run_row.is_empty():
		run_row = {
			"run_id": "n/a",
			"player_name": "Anonymous",
			"alert_trigger_count": 0,
			"raw_alert_count": 0,
			"ach_total_cost": 0.0,
			"exposure_mean_cumulative": 0.0,
			"exposure_max_cumulative": 0.0,
			"end_reason": "n/a"
		}

	var achievement: Dictionary = _achievement_for_row(run_row)
	var _stats_path_go: String = _resolve_stats_output_path_for_level(current_difficulty_level)
	_refresh_level_baseline_cache()
	_refresh_run_history_by_level(_stats_path_go)
	var exposure_payload: Dictionary = _build_comparison_chart_payload("exposure")
	var cost_payload: Dictionary = _build_comparison_chart_payload("cost")
	var alert_payload: Dictionary = _build_comparison_chart_payload("alerts")

	var player_name: String = Global.player_name.strip_edges()
	if player_name == "":
		player_name = "Care Team Lead"
	var reason_text: String = "You ended the simulation early." if reason == "manual" else "You successfully completed the full day."

	var payload := {
		"subtitle": "Great work, %s. %s" % [player_name, reason_text],
		"medal": str(achievement.get("medal", "Playroom Pal")),
		"medal_color": achievement.get("color", Color("#8fd3ff")),
		"summary": _game_over_summary_text(run_row),
		"exposure_series": exposure_payload.get("series", []),
		"exposure_status": exposure_payload.get("status", ""),
		"cost_series": cost_payload.get("series", []),
		"cost_status": cost_payload.get("status", ""),
		"alert_series": alert_payload.get("series", []),
		"alert_status": alert_payload.get("status", ""),
	}

	if game_over_layer.has_method("show_results"):
		game_over_layer.call("show_results", payload)
	else:
		game_over_layer.visible = true

func _hide_game_over() -> void:
	if game_over_layer == null:
		return
	if game_over_layer.has_method("hide_layer"):
		game_over_layer.call("hide_layer")
	else:
		game_over_layer.visible = false

func _return_to_title_from_run() -> void:
	_stop_autoplay_mode()
	_clear_game_controls_overlay()
	title_screen.show()
	map.hide()
	_hide_game_over()
	if player_name_input != null:
		player_name_input.text = ""
	Global.player_name = ""
	if player_name_auto_label != null:
		player_name_auto_label.visible = false
	_update_player_name_labels()
	_set_brave_mode(false)
	_set_health_mode(false)
	_refresh_title_level_dependent_data()
	_update_room_panel(true)

func _on_game_over_continue_pressed() -> void:
	_return_to_title_from_run()

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

func _update_title_screen_layout() -> void:
	if title_label == null or title_screen_vbox == null:
		return

	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var title_font_size := int(round(clampf(viewport_size.y * 0.14, float(title_screen_title_font_size_min), float(title_screen_title_font_size_max))))
	if title_label.label_settings != null:
		title_label.label_settings.font_size = title_font_size

	var title_top := maxf(18.0, viewport_size.y * title_screen_title_top_fraction)
	title_label.offset_top = title_top
	title_label.offset_bottom = title_top + maxf(140.0, float(title_font_size) * 1.8)

	var content_width := clampf(viewport_size.x * 0.52, 760.0, 1100.0)
	var content_left := -content_width * 0.5
	var content_top := clampf(viewport_size.y * title_screen_content_top_fraction, 220.0, viewport_size.y * 0.55)
	var content_height := clampf(viewport_size.y * title_screen_content_height_fraction, 260.0, viewport_size.y * 0.54)

	title_screen_vbox.anchor_left = 0.5
	title_screen_vbox.anchor_right = 0.5
	title_screen_vbox.anchor_top = 0.0
	title_screen_vbox.anchor_bottom = 0.0
	title_screen_vbox.offset_left = content_left
	title_screen_vbox.offset_right = content_left + content_width
	title_screen_vbox.offset_top = content_top
	title_screen_vbox.offset_bottom = content_top + content_height
	title_screen_vbox.alignment = 0

	if title_summary_gap != null:
		title_summary_gap.custom_minimum_size.y = clampf(viewport_size.y * title_screen_summary_gap_fraction, 120.0, 260.0)

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
		panel_alert_count_matrix.call("set_value", _current_alert_count_for_ui())
	if panel_sim_state_clock != null and panel_sim_state_clock.has_method("set_time_seconds"):
		panel_sim_state_clock.call("set_time_seconds", sim_time_s)

func _current_alert_count_for_ui() -> int:
	if use_raw_alert_counts_for_ui:
		return room_alert_raw_count_total
	return room_alert_trigger_count_total

func _alert_count_for_row(row: Dictionary, fallback_value: int = 0) -> int:
	if use_raw_alert_counts_for_ui:
		return int(row.get("raw_alert_count", row.get("alert_trigger_count", fallback_value)))
	return int(row.get("alert_trigger_count", fallback_value))

func _alert_count_label_text() -> String:
	if use_raw_alert_counts_for_ui:
		return "Raw Alerts"
	return "Alerts"

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
	if panel_brave_toggle_button != null:
		panel_brave_toggle_button.text = "BRAVE: ON" if brave_mode_active else "BRAVE: OFF"
	if panel_autoplay_toggle_button != null:
		panel_autoplay_toggle_button.text = "Exit Auto-play" if autoplay_mode_active else "Start Auto-play"
	if panel_pause_button != null:
		panel_pause_button.text = "Resume" if Global.is_simulation_paused else "Pause"
		if Global.is_simulation_paused:
			panel_pause_button.add_theme_color_override("font_color", Color("#fff0bf"))
			panel_pause_button.add_theme_color_override("font_hover_color", Color("#fff7de"))
		else:
			panel_pause_button.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			panel_pause_button.add_theme_color_override("font_hover_color", Color(0.93, 0.96, 1, 1))
	if panel_game_controls_button != null:
		panel_game_controls_button.text = "Close Controls" if game_controls_overlay_active else "Game Controls (?)"

	var has_rooms: bool = room_nodes.size() > 0
	var sim_active: bool = Global.is_simulation_active
	if pause_overlay != null:
		pause_overlay.visible = sim_active and Global.is_simulation_paused and not game_controls_overlay_active
	if game_controls_overlay != null:
		game_controls_overlay.visible = sim_active and game_controls_overlay_active

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
	if panel_brave_toggle_button != null:
		panel_brave_toggle_button.disabled = not sim_active
	if panel_autoplay_toggle_button != null:
		panel_autoplay_toggle_button.disabled = not sim_active
	if panel_speed_down_button != null:
		panel_speed_down_button.disabled = not sim_active
	if panel_speed_up_button != null:
		panel_speed_up_button.disabled = not sim_active
	if panel_pause_button != null:
		panel_pause_button.disabled = not sim_active
	if panel_game_controls_button != null:
		panel_game_controls_button.disabled = not sim_active

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

func _on_panel_brave_toggle_pressed() -> void:
	if not Global.is_simulation_active:
		return
	_set_brave_mode(not brave_mode_active)
	_refresh_panel_controls_state()

func _on_panel_autoplay_toggle_pressed() -> void:
	if not Global.is_simulation_active:
		return
	if autoplay_mode_active:
		_stop_autoplay_mode()
	else:
		_start_autoplay_mode()
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

func _on_panel_game_controls_pressed() -> void:
	_toggle_game_controls_overlay()

func _is_question_mark_pressed(event: InputEvent) -> bool:
	if not (event is InputEventKey):
		return false
	var key_event := event as InputEventKey
	if key_event.echo or not key_event.pressed:
		return false
	if key_event.unicode == 63:
		return true
	return key_event.shift_pressed and key_event.physical_keycode == KEY_SLASH

func _is_game_controls_close_input(event: InputEvent) -> bool:
	if _is_question_mark_pressed(event):
		return true
	if event.is_action_pressed("tutorial_exit") and not event.is_echo():
		return true
	if event.is_action_pressed("pause") and not event.is_echo():
		return true
	return false

func _clear_game_controls_overlay() -> void:
	game_controls_overlay_active = false
	game_controls_resume_paused_state = false
	if game_controls_overlay != null:
		game_controls_overlay.visible = false

func _update_game_controls_overlay_layout() -> void:
	if game_controls_size_rect == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var overlay_right_anchor := clampf(1.0 - room_panel_max_width_fraction, 0.0, 1.0)
	if game_controls_overlay != null:
		game_controls_overlay.anchor_left = 0.0
		game_controls_overlay.anchor_top = 0.0
		game_controls_overlay.anchor_right = overlay_right_anchor
		game_controls_overlay.anchor_bottom = 1.0
		game_controls_overlay.offset_left = 0.0
		game_controls_overlay.offset_top = 0.0
		game_controls_overlay.offset_right = 0.0
		game_controls_overlay.offset_bottom = 0.0
	game_controls_size_rect.custom_minimum_size = Vector2(
		viewport_size.x * GAME_CONTROLS_OVERLAY_WIDTH_FRACTION,
		viewport_size.y * GAME_CONTROLS_OVERLAY_HEIGHT_FRACTION
	)

func _set_game_controls_overlay(active: bool) -> void:
	if active and not Global.is_simulation_active:
		return
	if game_controls_overlay_active == active:
		_refresh_panel_controls_state()
		return

	if active:
		game_controls_resume_paused_state = Global.is_simulation_paused
		_set_pause_state(true)
		game_controls_overlay_active = true
	else:
		game_controls_overlay_active = false
		_set_pause_state(game_controls_resume_paused_state)

	_refresh_panel_controls_state()

func _toggle_game_controls_overlay() -> void:
	_set_game_controls_overlay(not game_controls_overlay_active)

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
				# Keep the dial text aligned with real-time load; the needle still caps at gauge max.
				panel_vl_gauge.call("set_current_value", maxf(selected_room.viral_load, 0.0))
		_update_alert_lamp_visual(Global.current_time_s())

	var exposure_stats: Dictionary = _exposure_stats()
	var current_hourly_cost: float = _current_room_ach_total() * Global.room_ach_cost_per_ach_hour
	_set_panel_value(panel_total_cost_value, "$%.2f" % Global.room_ach_total_cost, Color(1, 0.94, 0.82, 1))
	_set_panel_value(panel_ach_rate_value, "$%.2f/hr" % Global.room_ach_cost_per_ach_hour, Color(1, 0.94, 0.82, 1))
	_set_panel_value(panel_current_hourly_cost_value, "$%.2f/hr" % current_hourly_cost, Color(1, 0.94, 0.82, 1))
	_set_panel_value(panel_exposure_avg_value, "%.0f" % float(exposure_stats["mean"]), Color(0.8, 1, 0.9, 1))
	_set_panel_value(panel_exposure_max_value, "%.0f" % float(exposure_stats["max"]), Color(1, 0.84, 0.84, 1))
	_set_panel_value(panel_exposure_total_value, "%.0f" % float(exposure_stats["total"]), Color(0.78, 0.93, 1, 1))
	var ach_control_mode_text := "🅂 Standard allowing for 🄼 Manual override"
	if brave_mode_active:
		ach_control_mode_text = "🄱  BRAVE Mode - Risk Model based"
	elif health_mode_active:
		ach_control_mode_text = "🄷  Health Mode - BioSensor triggered"
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

func _read_last_run_summary_row(stats_file_path: String, level_filter: String = "") -> Dictionary:
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
			var row: Dictionary = parsed
			if level_filter != "":
				var row_level: String = _normalized_level_name(str(row.get("level", "")))
				if row_level != level_filter:
					continue
			return row
	return {}

func _refresh_last_run_summary(stats_file_path: String = "") -> void:
	if last_run_summary_label == null:
		return

	var effective_stats_file_path := stats_file_path
	if effective_stats_file_path == "":
		effective_stats_file_path = _resolve_stats_output_path_for_level(current_difficulty_level)

	var selected_level: String = _normalized_level_name(current_difficulty_level)
	if selected_level == "":
		selected_level = "Standard"

	var row: Dictionary = last_run_summary_by_level.get(selected_level, {})
	if row.is_empty():
		row = _read_last_run_summary_row(effective_stats_file_path, selected_level)
	if row.is_empty():
		last_run_summary_label.text = "Last Run: none yet"
		return

	var run_id: String = str(row.get("run_id", "n/a"))
	var player_name: String = str(row.get("player_name", ""))
	if player_name == "":
		player_name = "Anonymous"
	var alert_count: int = int(row.get("alert_trigger_count", 0))
	var alert_label: String = _alert_count_label_text()
	alert_count = _alert_count_for_row(row)
	var total_cost: float = float(row.get("ach_total_cost", 0.0))
	var exposure_mean: float = float(row.get("exposure_mean_cumulative", 0.0))
	var exposure_max: float = float(row.get("exposure_max_cumulative", 0.0))
	var end_reason: String = str(row.get("end_reason", "n/a"))

	last_run_summary_label.text = " %s (run: %s) | %s %d | Cost $%.2f | Exposure Avg %d" % [
		player_name,
		run_id,
		alert_label,
		alert_count,
		total_cost,
		exposure_mean
	]

func _refresh_title_level_dependent_data() -> void:
	var stats_path: String = _resolve_stats_output_path_for_level(current_difficulty_level)
	_preload_title_chart_payloads(stats_path)
	_refresh_last_run_summary(stats_path)
	_refresh_title_exposure_chart()
	_refresh_title_cost_chart()
	_refresh_title_alert_chart()

func _schedule_title_level_dependent_refresh() -> void:
	level_chart_refresh_token += 1
	var refresh_token: int = level_chart_refresh_token
	if level_chart_refresh_delay_s <= 0.0:
		_refresh_title_level_dependent_data()
		return
	await get_tree().create_timer(level_chart_refresh_delay_s).timeout
	if refresh_token != level_chart_refresh_token:
		return
	_refresh_title_level_dependent_data()

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
			# Use sensor-style persisted alert state so ACH stays elevated until a later
			# alert evaluation explicitly clears it.
			var alert_active_now: bool = _room_alert_state(room)
			room.apply_health_mode_alert(alert_active_now)

func _apply_brave_mode_ach_overrides() -> void:
	if not brave_mode_active:
		return

	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		if room.has_method("apply_brave_mode_alert"):
			# Apply hysteresis to prevent rapid ACH oscillations around threshold:
			# If ACH is already at max, use 95% threshold to drop to floor (lower bar to release)
			# If ACH is at floor, use 100% threshold to raise to max (higher bar to engage)
			var hysteresis_adjusted_threshold: float
			var brave_already_active: bool = is_equal_approx(room.ach_current, room.ach_max)
			if brave_already_active:
				# Already at max: use lower threshold (95%) to drop to floor
				hysteresis_adjusted_threshold = brave_mode_threshold * 0.95
			else:
				# Not at max: use normal threshold (100%) to raise to max
				hysteresis_adjusted_threshold = brave_mode_threshold
			var brave_alert_active_now: bool = room.viral_load >= hysteresis_adjusted_threshold
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

func _get_config_path_for_level(level: String) -> String:
	if not difficulty_level_map.has(level):
		level = "Standard"
	var suffix: String = difficulty_level_map[level]
	var base_dir: String = default_config_path.get_base_dir()
	return base_dir.path_join("config_childcare_%s.json" % suffix)

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
	var config_splash_version_text: String = str(config_data.get("splash_version_text", config_data.get("version", ""))).strip_edges()
	var config_room_infected_emission_per_s: float = float(config_data.get("room_infected_emission_per_s", 1.0))
	var config_room_non_vent_decay_per_s: float = float(config_data.get("room_non_vent_decay_per_s", 0.0))
	var config_health_baseline: float = float(config_data.get("health_mode_baseline_ach", config_data.get("baseline_ach", 3.0)))
	var config_health_max: float = float(config_data.get("health_mode_max_ach", config_data.get("max_ach", 9.0)))
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

	_restore_tutorial_card_sizing()

func _apply_overlay_card_sizing(use_autoplay_style: bool) -> void:
	var card_offset_left: float = autoplay_card_offset_left if use_autoplay_style else tutorial_card_offset_left_tutorial
	var card_offset_right: float = autoplay_card_offset_right if use_autoplay_style else tutorial_card_offset_right_tutorial
	var card_offset_top: float = autoplay_card_offset_top if use_autoplay_style else tutorial_card_offset_top_tutorial
	var card_offset_bottom: float = autoplay_card_offset_bottom if use_autoplay_style else tutorial_card_offset_bottom_tutorial
	var card_margin: int = autoplay_card_margin if use_autoplay_style else tutorial_card_margin_tutorial
	var step_font_size: int = autoplay_step_font_size if use_autoplay_style else tutorial_step_font_size_tutorial
	var title_font_size: int = autoplay_title_font_size if use_autoplay_style else tutorial_title_font_size_tutorial
	var body_font_size: int = autoplay_body_font_size if use_autoplay_style else tutorial_body_font_size_tutorial
	var image_min_height: float = autoplay_image_min_height if use_autoplay_style else tutorial_image_min_height_tutorial

	# Apply style and content sizing first, then measure and place.
	if tutorial_card_margin != null:
		tutorial_card_margin.add_theme_constant_override("margin_left", card_margin)
		tutorial_card_margin.add_theme_constant_override("margin_top", card_margin)
		tutorial_card_margin.add_theme_constant_override("margin_right", card_margin)
		tutorial_card_margin.add_theme_constant_override("margin_bottom", card_margin)

	if tutorial_step_label != null:
		tutorial_step_label.add_theme_font_size_override("font_size", step_font_size)
		tutorial_step_label.visible = (not use_autoplay_style) or autoplay_show_step_label
	if tutorial_title_label != null:
		tutorial_title_label.add_theme_font_size_override("font_size", title_font_size)
	if tutorial_body_label != null:
		tutorial_body_label.add_theme_font_size_override("font_size", body_font_size)
	if tutorial_slide_image != null:
		tutorial_slide_image.custom_minimum_size = Vector2(0.0, image_min_height)

	if tutorial_card != null:
		tutorial_card.update_minimum_size()
		var viewport_size := get_viewport().get_visible_rect().size
		# Calculate card position and size based on proportional offsets
		var left_px: float = card_offset_left * viewport_size.x
		var right_px: float = abs(card_offset_right) * viewport_size.x
		var top_px: float = card_offset_top * viewport_size.y
		var bottom_px: float = abs(card_offset_bottom) * viewport_size.y
		var card_x: float = left_px
		var card_width: float = max(1.0, viewport_size.x - left_px - right_px)
		var card_y: float = top_px
		var card_height: float = max(1.0, viewport_size.y - top_px - bottom_px)

		if overlay_card_bottom_priority_layout_enabled:
			# Bottom margin is hard; top offset is soft when content/min-size cannot fit preferred bounds.
			var safe_top_px: float = max(0.0, overlay_card_safe_top_fraction * viewport_size.y)
			var max_height_with_bottom_lock: float = max(1.0, viewport_size.y - bottom_px - safe_top_px)
			var preferred_height: float = max(1.0, viewport_size.y - top_px - bottom_px)
			var required_height: float = max(preferred_height, tutorial_card.get_combined_minimum_size().y)
			card_height = min(required_height, max_height_with_bottom_lock)

			var preferred_top_y: float = top_px
			var bottom_locked_y: float = viewport_size.y - bottom_px - card_height
			card_y = preferred_top_y
			if preferred_top_y + card_height > viewport_size.y - bottom_px:
				card_y = bottom_locked_y
			card_y = max(safe_top_px, card_y)
			# Clamp in case extreme sizes would otherwise push past the bottom edge.
			card_y = min(card_y, viewport_size.y - bottom_px - card_height)
		# Set position and size with zero anchors (absolute positioning)
		tutorial_card.anchor_left = 0.0
		tutorial_card.anchor_top = 0.0
		tutorial_card.anchor_right = 0.0
		tutorial_card.anchor_bottom = 0.0
		tutorial_card.offset_left = 0.0
		tutorial_card.offset_top = 0.0
		tutorial_card.offset_right = 0.0
		tutorial_card.offset_bottom = 0.0
		tutorial_card.position = Vector2(card_x, card_y)
		tutorial_card.size = Vector2(card_width, card_height)

func _queue_overlay_card_reflow(use_autoplay_style: bool) -> void:
	call_deferred("_apply_overlay_card_sizing", use_autoplay_style)

func _reflow_overlay_card_for_active_mode() -> void:
	if tutorial_overlay == null or tutorial_card == null:
		return
	if not tutorial_overlay.visible:
		return
	if autoplay_mode_active:
		_apply_overlay_card_sizing(true)
	elif tutorial_mode_active:
		_apply_overlay_card_sizing(false)

func _restore_tutorial_card_sizing() -> void:
	_apply_overlay_card_sizing(false)

func _set_overlay_nav_layout_for_autoplay() -> void:
	if tutorial_next_button == null:
		return
	var nav_row := tutorial_next_button.get_parent()
	if nav_row is BoxContainer:
		var row := nav_row as BoxContainer
		row.alignment = BoxContainer.ALIGNMENT_END
		# Keep hidden Back first, then Exit Auto-play, then Next on the far right.
		var target_idx: int = 0
		if tutorial_back_button != null and tutorial_back_button.get_parent() == row:
			row.move_child(tutorial_back_button, target_idx)
			target_idx += 1
		if tutorial_skip_button != null and tutorial_skip_button.get_parent() == row:
			row.move_child(tutorial_skip_button, target_idx)
			target_idx += 1
		if tutorial_next_button.get_parent() == row:
			row.move_child(tutorial_next_button, target_idx)

func _set_overlay_nav_layout_for_tutorial() -> void:
	if tutorial_next_button == null:
		return
	var nav_row := tutorial_next_button.get_parent()
	if nav_row is BoxContainer:
		var row := nav_row as BoxContainer
		row.alignment = BoxContainer.ALIGNMENT_BEGIN
		# Default tutorial order: Back, Next, Skip.
		var target_idx: int = 0
		if tutorial_back_button != null and tutorial_back_button.get_parent() == row:
			row.move_child(tutorial_back_button, target_idx)
			target_idx += 1
		if tutorial_next_button.get_parent() == row:
			row.move_child(tutorial_next_button, target_idx)
			target_idx += 1
		if tutorial_skip_button != null and tutorial_skip_button.get_parent() == row:
			row.move_child(tutorial_skip_button, target_idx)

func _set_overlay_navigation_visible(visible: bool) -> void:
	_set_overlay_nav_layout_for_tutorial()
	if tutorial_back_button != null:
		tutorial_back_button.visible = visible
	if tutorial_next_button != null:
		tutorial_next_button.visible = visible
	if tutorial_skip_button != null:
		tutorial_skip_button.visible = visible

func _configure_side_panel_button_focus_behavior() -> void:
	# Prevent lingering UI focus so keyboard actions (e.g., Space pause) do not
	# activate whichever side-panel button was clicked most recently.
	if panel_prev_room_button != null:
		panel_prev_room_button.focus_mode = Control.FOCUS_NONE
	if panel_next_room_button != null:
		panel_next_room_button.focus_mode = Control.FOCUS_NONE
	if panel_ach_down_button != null:
		panel_ach_down_button.focus_mode = Control.FOCUS_NONE
	if panel_ach_up_button != null:
		panel_ach_up_button.focus_mode = Control.FOCUS_NONE
	if panel_health_toggle_button != null:
		panel_health_toggle_button.focus_mode = Control.FOCUS_NONE
	if panel_brave_toggle_button != null:
		panel_brave_toggle_button.focus_mode = Control.FOCUS_NONE
	if panel_autoplay_toggle_button != null:
		panel_autoplay_toggle_button.focus_mode = Control.FOCUS_NONE
	if panel_speed_down_button != null:
		panel_speed_down_button.focus_mode = Control.FOCUS_NONE
	if panel_speed_up_button != null:
		panel_speed_up_button.focus_mode = Control.FOCUS_NONE
	if panel_pause_button != null:
		panel_pause_button.focus_mode = Control.FOCUS_NONE
	if panel_game_controls_button != null:
		panel_game_controls_button.focus_mode = Control.FOCUS_NONE

func _request_start_autoplay(config_path: String) -> void:
	if config_path == "":
		return
	_set_splash_version_override_from_config(config_path)
	start_simulation(config_path)
	_start_autoplay_mode()

func _request_start_with_prompt(config_path: String) -> void:
	if config_path == "":
		return
	_set_splash_version_override_from_config(config_path)
	start_simulation(config_path)
	_begin_tutorial_sequence()

func _start_autoplay_mode() -> void:
	autoplay_mode_active = true
	autoplay_cards_pool = _build_autoplay_cards()
	autoplay_seen_ids.clear()
	autoplay_completed_ids.clear()
	autoplay_show_counts.clear()
	autoplay_last_shown_s.clear()
	autoplay_interrupted_cooldown_until.clear()
	autoplay_current_card.clear()
	autoplay_current_actions.clear()
	autoplay_current_action_idx = 0
	autoplay_current_context.clear()
	autoplay_card_started_s = 0.0
	autoplay_card_started_wall_s = 0.0
	autoplay_wait_until_s = 0.0
	autoplay_post_delay_until_s = Global.current_time_s()
	autoplay_overlay_note = ""
	autoplay_rng.randomize()

	if tutorial_overlay != null:
		tutorial_overlay.visible = true
	if tutorial_back_button != null:
		tutorial_back_button.visible = false
	if tutorial_skip_button != null:
		tutorial_skip_button.visible = true
		tutorial_skip_button.text = "Exit Auto-play"
	if tutorial_next_button != null:
		tutorial_next_button.visible = true
		tutorial_next_button.text = "Next"
	_set_overlay_nav_layout_for_autoplay()
	_set_pause_state(false)

func _stop_autoplay_mode() -> void:
	autoplay_mode_active = false
	autoplay_cards_pool.clear()
	autoplay_show_counts.clear()
	autoplay_current_card.clear()
	autoplay_current_actions.clear()
	autoplay_current_action_idx = 0
	autoplay_current_context.clear()
	autoplay_overlay_note = ""
	autoplay_card_started_wall_s = 0.0
	autoplay_wait_until_s = 0.0
	autoplay_post_delay_until_s = 0.0
	if not tutorial_mode_active:
		if tutorial_highlight_frame != null:
			tutorial_highlight_frame.visible = false
		if tutorial_overlay != null:
			tutorial_overlay.visible = false
	if tutorial_skip_button != null:
		tutorial_skip_button.text = "Skip"
	_set_overlay_navigation_visible(true)

func _build_autoplay_cards() -> Array[Dictionary]:
	return [
		{
			"id": "auto_intro_welcome",
			"title": "Starting auto-play for the BRAVE Childcare Simulator",
			"body": "Watch a day in the BRAVE Childcare Center unfold.  Children and providers arrive and work through their daily schedule.  However, during the course of their day ",
			"target": [],
			"image": "res://Art/ChildcareCenter_RoomScene_SplashScreen.png",
			"priority": 10,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "immediate"},
			"actions": [
				{"op": "set_pause", "value": false},
				{"op": "set_overlay_note", "value": "Autoplay is live."},
				{"op": "wait", "duration_s": 4.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 20.0,
			"post_delay_s": 1.0,
			"interrupt_threshold": 70,
			"weight": 1.0,
		},
		{
			"id": "auto_intro_panel_overview",
			"title": "Side Panel: Status and Controls",
			"body": "The right panel tracks the Load and fan speed, or air changes per hour (ACH).  The guages show the levels in the currently selected room.",
			"target": ["PanelViralLoadGauge", "PanelAchGauge"],
			"image": "res://Art/tutorial/step_025_Counters_and_Controls.png",
			"priority": 12,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "time_window", "start_s": 60.0, "end_s": 600.0},
			"actions": [{"op": "wait", "duration_s": 8.0}],
			"min_show_time_s": 8.0,
			"max_show_time_s": 14.0,
			"post_delay_s": 2.0,
			"interrupt_threshold": 70,
			"weight": 1.0,
		},
		{
			"id": "auto_intro_room_cards",
			"title": "Side Panel: Rooms At A Glance",
			"body": "Each room card shows the load, it's trend, whether it's currenlty alerted, and the current ACH level.",
			"target": ["PanelRoomCards"],
			"image": "res://Art/tutorial/RoomCard.png",
			"priority": 14,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "time_window", "start_s": 300.0, "end_s": 1200.0},
			"actions": [
				{"op": "select_room", "room_id": "PreschoolRoom"},
				{"op": "wait", "duration_s": 2.0},
				{"op": "select_room", "room_id": "CommonRoomRoom"},
				{"op": "wait", "duration_s": 2.0},
				{"op": "select_room", "room_id": "YoungerToddlerRoom"},
				{"op": "wait", "duration_s": 3.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 14.0,
			"post_delay_s": 2.0,
			"interrupt_threshold": 75,
			"weight": 1.0,
		},
		{
			"id": "auto_intro_ach_controls",
			"title": "ACH Adjustments",
			"body": "Higher ACH lowers load faster, but costs more. We increase it when risk rises.",
			"target": ["PanelAchDownButton", "PanelAchUpButton"],
			"image": "res://Art/tutorial/ACH_controls_Filtration.png",
			"priority": 16,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "time_window", "start_s": 420.0, "end_s": 1800.0},
			"actions": [
				{"op": "select_room", "room_id": "CommonRoom"},
				{"op": "add_ach", "room_id": "CommonRoom", "delta": 1.0},
				{"op": "wait", "duration_s": 6.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 14.0,
			"post_delay_s": 2.0,
			"interrupt_threshold": 75,
			"weight": 1.0,
		},
		{
			"id": "auto_sensor_cycle_explainer",
			"title": "BioSensor tracks bioaerosol levels.",
			"body": "The biosensor checks rooms periodically, then alerts if the load is high.",
			"target": ["SensorCountdownCard", "PanelAlertCountMatrix"],
			"image": "res://Art/tutorial/BRAVE_biosensor.png",
			"priority": 28,
			"one_shot": false,
			"cooldown_s": 50*60,
			"max_shows": 3,
			"trigger": {"type": "sensor_due_window", "comparator": "<=", "value": 20.0},
			"actions": [{"op": "wait", "duration_s": 5.0}],
			"min_show_time_s": 8.0,
			"max_show_time_s": 12.0,
			"post_delay_s": 2.0,
			"interrupt_threshold": 80,
			"weight": 1.0,
		},
		{
			"id": "auto_health_mode_demo",
			"title": "Health Mode",
			"body": "Health mode demonstrates how the smart building can function to raise ACH automatically when the biosensor is trigered to ensure cleaner air for the occupants.",
			"target": ["PanelHealthToggleButton"],
			"image": "res://Art/tutorial/step_06_health_mode.png",
			"priority": 35,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "runtime_progress", "progress_min": 0.25, "progress_max": 0.60},
			"actions": [
				{"op": "set_health_mode", "value": true},
				{"op": "wait", "duration_s": 30.0},
				
			],
			"min_show_time_s": 15.0,
			"max_show_time_s": 25.0,
			"post_delay_s": 2.0,
			"interrupt_threshold": 82,
			"weight": 1.0,
		},
		{
			"id": "auto_alert_any_room",
			"title": "Alert Detected",
			"body": "A room crossed the alert threshold. Focusing now.",
			"target": ["PanelAlertCountMatrix"],
			"image": "res://Art/tutorial/BRAVE_biosensor.png",
			"priority": 80,
			"one_shot": false,
			"cooldown_s": 45*60,
			"max_shows": 4,
			"trigger": {"type": "room_alert_active", "value": true},
			"actions": [
				{"op": "focus_room", "room_id": "$triggered_room_id"},
				{"op": "wait", "duration_s": 4.0}
			],
			"min_show_time_s": 12.0,
			"max_show_time_s": 25.0,
			"can_interrupt": false,
			"post_delay_s": 1.0,
			"interrupt_threshold": 90,
			"weight": 1.0,
		},
		{
			"id": "auto_alert_raise_ach_to_safe",
			"title": "Activating Max Filtering",
			"body": "Raising ACH for this room to reduce the load and make the environment cleaner.",
			"target": ["PanelAchGauge", "PanelAchUpButton"],
			"image": "res://Art/tutorial/ACH_controls_Filtration.png",
			"priority": 85,
			"one_shot": false,
			"cooldown_s": 300.0,
			"max_shows": 4,
			"trigger": {"type": "room_alert_active", "value": true},
			"actions": [
				{"op": "select_room", "room_id": "$triggered_room_id"},
				{"op": "set_ach", "room_id": "$triggered_room_id", "value": 6.0},
				{"op": "wait", "duration_s": 8.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 16.0,
			"can_interrupt": true,
			"post_delay_s": 1.0,
			"interrupt_threshold": 92,
			"weight": 1.0,
		},
		{
			"id": "auto_alert_recheck_trend",
			"title": "High Loads can persist",
			"body": "This room's load remains elevated.  Delays in increasing ACH can allow loads to get ahead of practical filtering.  Enhanced risk models can anticipate these rises and activate ACH changes before biosensors alert, intelligent controls help maximize a healthy environment while limiting disruptions and using excessive resources.  Activating BRAVE mode which simulates a high performing risk model.",
			"target": ["PanelViralLoadGauge"],
			"image": "res://Art/tutorial/RoomCard.png",
			"priority": 70,
			"one_shot": false,
			"cooldown_s": 25*60.0,
			"max_shows": 3,
			"trigger": {"type": "room_viral_load", "comparator": ">", "value": 800.0},
			"actions": [
				{"op": "focus_room", "room_id": "$triggered_room_id"},
				{"op": "wait", "duration_s": 10.0},
				{"op": "set_brave_mode", "value": true},
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 18.0,
			"can_interrupt": true,
			"post_delay_s": 1.0,
			"interrupt_threshold": 90,
			"weight": 1.0,
		},
		{
			"id": "auto_multiroom_pressure_response",
			"title": "Multiple Rooms over Threshold",
			"body": "More than one room is alerting. We will turn on Health Mode to help automate the challenge of monitoring and adjusting .",
			"target": ["PanelHealthToggleButton", "PanelAlertCountMatrix"],
			"image": "res://Art/tutorial/step_06_health_mode.png",
			"priority": 90,
			"one_shot": false,
			"cooldown_s": 900.0,
			"trigger": {"type": "room_alert_active", "value": true, "min_alert_room_count": 2},
			"actions": [
				{"op": "set_health_mode", "value": true},
				{"op": "wait", "duration_s": 20.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 22.0,
			"can_interrupt": true,
			"post_delay_s": 2.0,
			"interrupt_threshold": 95,
			"weight": 1.0,
		},
		{
			"id": "auto_follow_highest_load_room",
			"title": "Risk Hotspot",
			"body": "Tracking the highest-load room while the simulation evolves.",
			"target": ["PanelViralLoadGauge"],
			"image": "res://Art/tutorial/RoomCard.png",
			"priority": 30,
			"one_shot": false,
			"cooldown_s": 900.0,
			"trigger": {"type": "runtime_progress", "progress_min": 0.60, "progress_max": 0.95},
			"actions": [
				{"op": "focus_room", "room_id": "$highest_viral_load_room_id"},
				{"op": "wait", "duration_s": 10.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 16.0,
			"post_delay_s": 2.0,
			"interrupt_threshold": 85,
			"weight": 1.5,
		},
		{
			"id": "auto_speedup_mid_late",
			"title": "Midday Fast Forward",
			"body": "Now that we've seen how this all works together .",
			"target": ["PanelSpeedUpButton"],
			"image": "res://Art/FastForward_Arrows.png",
			"priority": 75,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "runtime_progress", "progress_min": 0.50, "progress_max": 0.55},
			"actions": [
				{"op": "set_speed", "value": 2.4},
				{"op": "set_overlay_note", "value": "Fast forwarding to afternoon dynamics."},
				{"op": "wait", "duration_s": 6.0}
			],
			"min_show_time_s": 8.0,
			"max_show_time_s": 12.0,
			"can_interrupt": true,
			"post_delay_s": 1.0,
			"interrupt_threshold": 88,
			"weight": 1.0,
		},
		{
			"id": "auto_speedup_finale",
			"title": "Fast Forward through the rest of the day",
			"body": "Running the final stretch at higher speed to reach day-end results.",
			"target": ["PanelSpeedUpButton"],
			"image": "res://Art/tutorial/FastForward_Arrows.png",
			"priority": 95,
			"one_shot": true,
			"cooldown_s": 0.0,
			"trigger": {"type": "runtime_progress", "progress_min": 0.90, "progress_max": 1.00},
			"actions": [
				{"op": "set_speed", "value": 3.0},
				{"op": "wait", "duration_s": 4.0}
			],
			"min_show_time_s": 12.0,
			"max_show_time_s": 10.0,
			"can_interrupt": true,
			"post_delay_s": 1.0,
			"interrupt_threshold": 100,
			"weight": 1.0,
		},
		{
			"id": "auto_default_watch",
			"title": "Watching Things Unfold",
			"body": "Sit back and watch as the day continues.",
			"target": [],
			"image": "res://Art/SitBackAndWatch.png",
			"priority": 6,
			"one_shot": false,
			"cooldown_s": 4.0,
			"trigger": {"type": "runtime_progress", "progress_min": 0.0, "progress_max": 1.0},
			"actions": [
				{"op": "wait", "duration_s": 12.0}
			],
			"min_show_time_s": 12.0,
			"max_show_time_s": 18.0,
			"post_delay_s": 1.0,
			"interrupt_threshold": 70,
			"requires_all_cards_seen_once": true,
			"weight": 6.0,
		},
	]

func _autoplay_all_non_default_seen_once() -> bool:
	for card in autoplay_cards_pool:
		var card_id: String = str(card.get("id", ""))
		if card_id == "" or card_id == "auto_default_watch":
			continue
		if not autoplay_seen_ids.has(card_id):
			return false
	return true

func _autoplay_wall_time_s() -> float:
	return Time.get_ticks_msec() / 1000.0

func _autoplay_runtime_progress() -> float:
	var span: float = Global.runtime_end_s - Global.runtime_start_s
	if span <= 0.0:
		return 0.0
	return clampf((Global.current_time_s() - Global.runtime_start_s) / span, 0.0, 1.0)

func _autoplay_alerting_rooms() -> Array:
	var alerting: Array = []
	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		if room.viral_load >= room_alert_threshold_vl:
			alerting.append(room)
	return alerting

func _autoplay_highest_viral_load_room() -> Variant:
	var best_room = null
	var best_load := -INF
	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		if room.viral_load > best_load:
			best_load = room.viral_load
			best_room = room
	return best_room

func _autoplay_find_room_by_id(room_id: String) -> Variant:
	if room_id == "":
		return null
	for room in room_nodes:
		if not is_instance_valid(room):
			continue
		if str(room.room_id) == room_id:
			return room
	return null

func _autoplay_next_sensor_due_remaining_s() -> float:
	if room_alert_check_interval_s <= 0.0 or room_nodes.is_empty():
		return INF
	var now_s: float = Global.current_time_s()
	var next_due := INF
	for room in room_nodes:
		var room_id: String = room.room_id
		var last_eval: float = float(room_alert_last_eval_s.get(room_id, now_s))
		var candidate: float = last_eval + room_alert_check_interval_s
		next_due = min(next_due, candidate)
	if next_due == INF:
		return INF
	return max(0.0, next_due - now_s)

func _compare_variant(value: Variant, comparator: String, expected: Variant) -> bool:
	match comparator:
		">":
			return float(value) > float(expected)
		">=":
			return float(value) >= float(expected)
		"<":
			return float(value) < float(expected)
		"<=":
			return float(value) <= float(expected)
		"==":
			return value == expected
		"!=":
			return value != expected
		_:
			return false

func _autoplay_trigger_matches(card: Dictionary) -> Dictionary:
	var trigger: Dictionary = card.get("trigger", {"type": "immediate"})
	var trigger_type: String = str(trigger.get("type", "immediate"))
	var now_s: float = Global.current_time_s()
	var context: Dictionary = {}

	if trigger_type == "immediate":
		var card_id := str(card.get("id", ""))
		if autoplay_seen_ids.has(card_id):
			return {"matched": false, "context": context}
		return {"matched": true, "context": context}

	if trigger_type == "time_window":
		var start_s: float = float(trigger.get("start_s", -INF))
		var end_s: float = float(trigger.get("end_s", INF))
		return {"matched": now_s >= start_s and now_s <= end_s, "context": context}

	if trigger_type == "runtime_progress":
		var progress: float = _autoplay_runtime_progress()
		var progress_min: float = float(trigger.get("progress_min", 0.0))
		var progress_max: float = float(trigger.get("progress_max", 1.0))
		return {"matched": progress >= progress_min and progress <= progress_max, "context": context}

	if trigger_type == "sensor_due_window":
		var remaining_s := _autoplay_next_sensor_due_remaining_s()
		var comparator: String = str(trigger.get("comparator", "<="))
		var expected: float = float(trigger.get("value", 180.0))
		return {"matched": remaining_s != INF and _compare_variant(remaining_s, comparator, expected), "context": context}

	if trigger_type == "room_alert_active":
		var alerting_rooms: Array = _autoplay_alerting_rooms()
		var min_alert_room_count: int = int(trigger.get("min_alert_room_count", 1))
		if alerting_rooms.size() < min_alert_room_count:
			return {"matched": false, "context": context}
		var chosen_room = alerting_rooms[0]
		for room in alerting_rooms:
			if room.viral_load > chosen_room.viral_load:
				chosen_room = room
		context["triggered_room_id"] = str(chosen_room.room_id)
		return {"matched": true, "context": context}

	if trigger_type == "room_viral_load":
		var comparator: String = str(trigger.get("comparator", ">"))
		var threshold: float = float(trigger.get("value", room_alert_threshold_vl))
		var candidate = null
		for room in room_nodes:
			if not is_instance_valid(room):
				continue
			if _compare_variant(room.viral_load, comparator, threshold):
				if candidate == null or room.viral_load > candidate.viral_load:
					candidate = room
		if candidate == null:
			return {"matched": false, "context": context}
		context["triggered_room_id"] = str(candidate.room_id)
		return {"matched": true, "context": context}

	if trigger_type == "mode_state":
		var mode_name: String = str(trigger.get("mode", "health"))
		var expected_state: bool = bool(trigger.get("value", true))
		if mode_name == "health":
			return {"matched": health_mode_active == expected_state, "context": context}
		if mode_name == "brave":
			return {"matched": brave_mode_active == expected_state, "context": context}
		return {"matched": false, "context": context}

	if trigger_type == "sim_speed_state":
		var comparator: String = str(trigger.get("comparator", ">="))
		var expected_speed: float = float(trigger.get("value", 1.0))
		return {"matched": _compare_variant(Global.sim_speed_scale, comparator, expected_speed), "context": context}

	return {"matched": false, "context": context}

func _autoplay_card_allowed(card: Dictionary, now_s: float) -> bool:
	var card_id: String = str(card.get("id", ""))
	if card_id == "":
		return false
	if bool(card.get("requires_all_cards_seen_once", false)) and not _autoplay_all_non_default_seen_once():
		return false
	if bool(card.get("one_shot", false)) and autoplay_completed_ids.has(card_id):
		return false
	var max_shows: int = int(card.get("max_shows", -1))
	if max_shows >= 0 and int(autoplay_show_counts.get(card_id, 0)) >= max_shows:
		return false
	var cooldown_s: float = float(card.get("cooldown_s", 0.0))
	var last_shown_s: float = float(autoplay_last_shown_s.get(card_id, -INF))
	if cooldown_s > 0.0 and now_s < last_shown_s + cooldown_s:
		return false
	if autoplay_interrupted_cooldown_until.has(card_id):
		if now_s < float(autoplay_interrupted_cooldown_until[card_id]):
			return false
	return true

func _autoplay_pick_weighted(candidates: Array[Dictionary]) -> Dictionary:
	if candidates.is_empty():
		return {}
	var total_weight := 0.0
	for entry in candidates:
		total_weight += max(0.01, float(entry.get("weight", 1.0)))
	var roll := autoplay_rng.randf_range(0.0, total_weight)
	var running := 0.0
	for entry in candidates:
		running += max(0.01, float(entry.get("weight", 1.0)))
		if roll <= running:
			return entry
	return candidates[0]

func _autoplay_choose_next_card() -> Dictionary:
	if autoplay_cards_pool.is_empty():
		return {}
	var now_s: float = Global.current_time_s()
	var high_priority: Array[Dictionary] = []
	var normal_priority: Array[Dictionary] = []
	for card in autoplay_cards_pool:
		if not _autoplay_card_allowed(card, now_s):
			continue
		var trigger_eval: Dictionary = _autoplay_trigger_matches(card)
		if not bool(trigger_eval.get("matched", false)):
			continue
		var entry: Dictionary = card.duplicate(true)
		entry["_context"] = trigger_eval.get("context", {})
		entry["_priority"] = int(card.get("priority", 0))
		entry["_seen"] = autoplay_seen_ids.has(str(card.get("id", "")))
		entry["weight"] = float(card.get("weight", 1.0))
		if int(entry["_priority"]) >= 70:
			high_priority.append(entry)
		else:
			normal_priority.append(entry)

	high_priority.sort_custom(func(a: Dictionary, b: Dictionary): return int(a["_priority"]) > int(b["_priority"]))
	if not high_priority.is_empty():
		return high_priority[0]

	if _autoplay_all_non_default_seen_once():
		for entry in normal_priority:
			if str(entry.get("id", "")) == "auto_default_watch":
				return entry

	normal_priority.sort_custom(func(a: Dictionary, b: Dictionary):
		if bool(a["_seen"]) != bool(b["_seen"]):
			return not bool(a["_seen"])
		if int(a["_priority"]) != int(b["_priority"]):
			return int(a["_priority"]) > int(b["_priority"])
		return str(a.get("id", "")) < str(b.get("id", ""))
	)
	if normal_priority.is_empty():
		return {}

	var unseen_candidates: Array[Dictionary] = []
	for entry in normal_priority:
		if not bool(entry.get("_seen", false)):
			unseen_candidates.append(entry)
	if not unseen_candidates.is_empty():
		return _autoplay_pick_weighted(unseen_candidates)
	return _autoplay_pick_weighted(normal_priority)

func _autoplay_should_interrupt(current_card: Dictionary, incoming_card: Dictionary) -> bool:
	if current_card.is_empty() or incoming_card.is_empty():
		return false
	var current_priority: int = int(current_card.get("priority", 0))
	var incoming_priority: int = int(incoming_card.get("priority", 0))
	if incoming_priority <= current_priority:
		return false
	var threshold: int = int(current_card.get("interrupt_threshold", AUTOPLAY_DEFAULT_INTERRUPT_THRESHOLD))
	if incoming_priority >= threshold:
		return true
	if bool(current_card.get("can_interrupt", false)):
		return incoming_priority >= current_priority
	return false

func _autoplay_render_card(card: Dictionary, status_text: String = "Narration") -> void:
	_apply_overlay_card_sizing(true)
	if tutorial_overlay != null:
		tutorial_overlay.visible = true
	if tutorial_step_label != null:
		var step_text: String = "Autoplay | %s" % status_text
		if autoplay_mode_active and not autoplay_current_card.is_empty() and str(autoplay_current_card.get("id", "")) == str(card.get("id", "")):
			var max_show_s: float = max(0.0, float(autoplay_current_card.get("max_show_time_s", AUTOPLAY_DEFAULT_MAX_SHOW_S)))
			var elapsed_s: float = max(0.0, _autoplay_wall_time_s() - autoplay_card_started_wall_s)
			var left_s: int = int(max(0.0, ceili(max_show_s - elapsed_s)))
			step_text += " | Max %ds" % left_s
		tutorial_step_label.text = step_text
	if tutorial_title_label != null:
		tutorial_title_label.text = str(card.get("title", "Autoplay"))
	if tutorial_body_label != null:
		var body_text: String = str(card.get("body", ""))
		if autoplay_body_max_chars > 0 and body_text.length() > autoplay_body_max_chars:
			body_text = "%s..." % body_text.substr(0, autoplay_body_max_chars).rstrip(" ")
		if autoplay_include_status_note and autoplay_overlay_note != "":
			body_text += "\n\nStatus: %s" % autoplay_overlay_note
		tutorial_body_label.text = body_text
	if tutorial_slide_video != null:
		tutorial_slide_video.stop()
		tutorial_slide_video.stream = null
		tutorial_slide_video.visible = false
	if tutorial_slide_image != null:
		var image_path: String = str(card.get("image", "")).strip_edges()
		var slide_texture := _tutorial_texture_for_path(image_path)
		tutorial_slide_image.texture = slide_texture
		tutorial_slide_image.visible = slide_texture != null
	# Re-apply after text/image updates so min-size expansion cannot push the bottom off-screen.
	_apply_overlay_card_sizing(true)
	_queue_overlay_card_reflow(true)
	_overlay_update_highlight(card)

func _overlay_update_highlight(card: Dictionary) -> void:
	if tutorial_highlight_frame == null:
		return
	var target_keys := _tutorial_target_keys(card)
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

func _autoplay_resolve_room_id(action: Dictionary, context: Dictionary) -> String:
	var raw_room_id: String = str(action.get("room_id", "")).strip_edges()
	if raw_room_id == "$triggered_room_id":
		return str(context.get("triggered_room_id", ""))
	if raw_room_id == "$highest_viral_load_room_id":
		var room = _autoplay_highest_viral_load_room()
		if room != null:
			return str(room.room_id)
		return ""
	return raw_room_id

func _autoplay_select_room(room_id: String) -> bool:
	var room = _autoplay_find_room_by_id(room_id)
	if room == null:
		return false
	for idx in range(room_nodes.size()):
		if selected_room_idx == idx and is_instance_valid(room_nodes[idx]):
			room_nodes[idx].set_selected(false)
		if room_nodes[idx] == room:
			selected_room_idx = idx
	if selected_room_idx >= 0 and selected_room_idx < room_nodes.size() and is_instance_valid(room_nodes[selected_room_idx]):
		room_nodes[selected_room_idx].set_selected(true)
	_update_room_panel(true)
	return true

func _autoplay_collect_collision_points(node: Node, points: Array[Vector2]) -> void:
	for child in node.get_children():
		if child is CollisionPolygon2D:
			var collision_polygon := child as CollisionPolygon2D
			for local_point in collision_polygon.polygon:
				points.append(collision_polygon.global_transform * local_point)
		_autoplay_collect_collision_points(child, points)

func _autoplay_room_collision_bounds(room: Node2D) -> Rect2:
	var points: Array[Vector2] = []
	_autoplay_collect_collision_points(room, points)

	if points.is_empty():
		return Rect2(room.global_position - Vector2(120.0, 120.0), Vector2(240.0, 240.0))

	var min_pos := Vector2(INF, INF)
	var max_pos := Vector2(-INF, -INF)
	for point in points:
		min_pos.x = min(min_pos.x, point.x)
		min_pos.y = min(min_pos.y, point.y)
		max_pos.x = max(max_pos.x, point.x)
		max_pos.y = max(max_pos.y, point.y)

	return Rect2(min_pos, (max_pos - min_pos).abs())

func _autoplay_zoom_for_bounds(bounds: Rect2) -> float:
	var padded_bounds: Rect2 = _autoplay_padded_focus_bounds(bounds)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return camera_2d.zoom.x if camera_2d != null else 1.0

	var padded_size: Vector2 = padded_bounds.size
	padded_size.x = maxf(padded_size.x, 1.0)
	padded_size.y = maxf(padded_size.y, 1.0)

	var zoom_x: float = viewport_size.x / padded_size.x
	var zoom_y: float = viewport_size.y / padded_size.y
	var target_zoom: float = minf(zoom_x, zoom_y)
	return clampf(target_zoom, autoplay_focus_zoom_min, autoplay_focus_zoom_max)

func _autoplay_padded_focus_bounds(bounds: Rect2) -> Rect2:
	var base_padding_fraction: float = maxf(0.0, autoplay_focus_padding_fraction)
	var right_padding_fraction: float = maxf(base_padding_fraction, autoplay_focus_right_padding_fraction)
	var left_padding: float = bounds.size.x * base_padding_fraction
	var right_padding: float = bounds.size.x * right_padding_fraction
	var vertical_padding: float = bounds.size.y * base_padding_fraction

	var padded_position := Vector2(bounds.position.x - left_padding, bounds.position.y - vertical_padding)
	var padded_size := Vector2(
		bounds.size.x + left_padding + right_padding,
		bounds.size.y + vertical_padding * 2.0
	)
	return Rect2(padded_position, padded_size)

func _autoplay_tween_camera_to_room(room: Node2D) -> void:
	if camera_2d == null:
		return

	var bounds := _autoplay_room_collision_bounds(room)
	var padded_bounds: Rect2 = _autoplay_padded_focus_bounds(bounds)
	var target_position := padded_bounds.position + padded_bounds.size * 0.5
	var target_zoom_scalar := _autoplay_zoom_for_bounds(bounds)
	var duration := maxf(0.01, autoplay_camera_tween_duration_s)

	if autoplay_camera_focus_tween != null and autoplay_camera_focus_tween.is_running():
		autoplay_camera_focus_tween.kill()

	autoplay_camera_focus_tween = create_tween()
	autoplay_camera_focus_tween.set_parallel(true)
	autoplay_camera_focus_tween.tween_property(camera_2d, "position", target_position, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	autoplay_camera_focus_tween.tween_property(camera_2d, "zoom", Vector2(target_zoom_scalar, target_zoom_scalar), duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _autoplay_focus_room(room_id: String) -> bool:
	if not _autoplay_select_room(room_id):
		return false
	var room = _autoplay_find_room_by_id(room_id)
	if room == null:
		return false
	_autoplay_tween_camera_to_room(room)
	return true

func _autoplay_execute_action(action: Dictionary, context: Dictionary) -> bool:
	var op: String = str(action.get("op", "")).strip_edges()
	if op == "":
		return true

	if op == "wait":
		if autoplay_wait_until_s <= 0.0:
			autoplay_wait_until_s = Global.current_time_s() + max(0.0, float(action.get("duration_s", 1.0)))
		if Global.current_time_s() < autoplay_wait_until_s:
			return false
		autoplay_wait_until_s = 0.0
		return true

	if op == "set_overlay_note":
		autoplay_overlay_note = str(action.get("value", "")).strip_edges()
		_autoplay_render_card(autoplay_current_card, "Narration")
		return true

	if op == "select_room":
		return _autoplay_select_room(_autoplay_resolve_room_id(action, context))

	if op == "focus_room":
		return _autoplay_focus_room(_autoplay_resolve_room_id(action, context))

	if op == "set_ach":
		var room_id := _autoplay_resolve_room_id(action, context)
		var room = _autoplay_find_room_by_id(room_id)
		if room == null:
			return true
		room.adjust_ach(float(action.get("value", room.ach_current)) - room.ach_current)
		_update_room_panel(true)
		return true

	if op == "add_ach":
		var room_id := _autoplay_resolve_room_id(action, context)
		var room = _autoplay_find_room_by_id(room_id)
		if room == null:
			return true
		room.adjust_ach(float(action.get("delta", 0.0)))
		_update_room_panel(true)
		return true

	if op == "set_health_mode":
		_set_health_mode(bool(action.get("value", true)))
		_update_room_panel(true)
		return true

	if op == "set_brave_mode":
		_set_brave_mode(bool(action.get("value", true)))
		_update_room_panel(true)
		return true

	if op == "set_pause":
		_set_pause_state(bool(action.get("value", false)))
		return true

	if op == "set_speed":
		_apply_sim_speed_scale(float(action.get("value", Global.sim_speed_scale)))
		_update_room_panel(true)
		return true

	if op == "add_speed":
		_adjust_sim_speed_scale(float(action.get("delta", 0.0)))
		_update_room_panel(true)
		return true

	return true

func _autoplay_begin_card(card: Dictionary) -> void:
	autoplay_current_card = card.duplicate(true)
	autoplay_current_context = autoplay_current_card.get("_context", {})
	autoplay_current_actions.clear()
	var raw_actions = autoplay_current_card.get("actions", [])
	if raw_actions is Array:
		for action in raw_actions:
			if action is Dictionary:
				autoplay_current_actions.append(action)
	autoplay_current_action_idx = 0
	autoplay_card_started_s = Global.current_time_s()
	autoplay_card_started_wall_s = _autoplay_wall_time_s()
	autoplay_wait_until_s = 0.0
	autoplay_overlay_note = ""
	var card_id: String = str(autoplay_current_card.get("id", ""))
	autoplay_seen_ids[card_id] = true
	autoplay_show_counts[card_id] = int(autoplay_show_counts.get(card_id, 0)) + 1
	autoplay_last_shown_s[card_id] = autoplay_card_started_s
	_autoplay_render_card(autoplay_current_card, "Triggered")

func _autoplay_finish_current_card(interrupted: bool = false) -> void:
	if autoplay_current_card.is_empty():
		return
	var now_s: float = Global.current_time_s()
	var card_id: String = str(autoplay_current_card.get("id", ""))
	if interrupted:
		autoplay_interrupted_cooldown_until[card_id] = now_s + AUTOPLAY_INTERRUPT_COOLDOWN_S
	else:
		autoplay_completed_ids[card_id] = true
		autoplay_post_delay_until_s = now_s + max(0.0, float(autoplay_current_card.get("post_delay_s", 0.0)))
	autoplay_current_card.clear()
	autoplay_current_actions.clear()
	autoplay_current_action_idx = 0
	autoplay_current_context.clear()
	autoplay_card_started_s = 0.0
	autoplay_card_started_wall_s = 0.0
	autoplay_wait_until_s = 0.0
	autoplay_overlay_note = ""
	if tutorial_highlight_frame != null:
		tutorial_highlight_frame.visible = false

func _autoplay_find_card_by_id(card_id: String) -> Dictionary:
	if card_id == "":
		return {}
	for card in autoplay_cards_pool:
		if str(card.get("id", "")) == card_id:
			return card.duplicate(true)
	return {}

func _autoplay_manual_next_card() -> void:
	if not autoplay_mode_active:
		return

	var current_id: String = str(autoplay_current_card.get("id", ""))
	if not autoplay_current_card.is_empty():
		# Explicit manual advance should not wait for min_show_time_s.
		_autoplay_finish_current_card(true)

	var next_card: Dictionary = _autoplay_choose_next_card()
	if not next_card.is_empty() and str(next_card.get("id", "")) == current_id:
		next_card = {}

	if next_card.is_empty():
		next_card = _autoplay_find_card_by_id("auto_default_watch")
		if not next_card.is_empty():
			next_card["_context"] = _autoplay_trigger_matches(next_card).get("context", {})

	if next_card.is_empty():
		return

	_autoplay_begin_card(next_card)
	_autoplay_render_card(autoplay_current_card, "Manual")

func _autoplay_tick() -> void:
	if not autoplay_mode_active or not Global.is_simulation_active:
		return
	if Global.current_time_s() < autoplay_post_delay_until_s:
		return
	var elapsed_current_s: float = _autoplay_wall_time_s() - autoplay_card_started_wall_s

	var incoming_card: Dictionary = _autoplay_choose_next_card()
	if autoplay_current_card.is_empty():
		if incoming_card.is_empty():
			return
		_autoplay_begin_card(incoming_card)
	else:
		if not incoming_card.is_empty() and str(incoming_card.get("id", "")) != str(autoplay_current_card.get("id", "")):
			var current_min_show_s: float = max(8.0, float(autoplay_current_card.get("min_show_time_s", 0.0)))
			var current_actions_finished: bool = autoplay_current_action_idx >= autoplay_current_actions.size()
			if current_actions_finished and elapsed_current_s >= current_min_show_s and _autoplay_should_interrupt(autoplay_current_card, incoming_card):
				_autoplay_finish_current_card(true)
				_autoplay_begin_card(incoming_card)

	if autoplay_current_card.is_empty():
		return

	var min_show: float = max(8.0, float(autoplay_current_card.get("min_show_time_s", 0.0)))
	var max_show: float = max(min_show, float(autoplay_current_card.get("max_show_time_s", AUTOPLAY_DEFAULT_MAX_SHOW_S)))
	var elapsed: float = _autoplay_wall_time_s() - autoplay_card_started_wall_s
	_autoplay_render_card(autoplay_current_card, "Narration")

	while autoplay_current_action_idx < autoplay_current_actions.size():
		var action: Dictionary = autoplay_current_actions[autoplay_current_action_idx]
		if not _autoplay_execute_action(action, autoplay_current_context):
			break
		autoplay_current_action_idx += 1

	var actions_finished: bool = autoplay_current_action_idx >= autoplay_current_actions.size()
	if elapsed >= max_show:
		actions_finished = true
	if actions_finished and elapsed >= min_show:
		_autoplay_finish_current_card(false)

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
			"title": "Fifty people and 8 Rooms, its a lot to manage",
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
	_restore_tutorial_card_sizing()

	if tutorial_overlay != null:
		tutorial_overlay.visible = true
	_set_overlay_navigation_visible(true)

	_show_tutorial_step()
	_queue_overlay_card_reflow(false)

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
	_set_overlay_navigation_visible(true)
	_set_pause_state(tutorial_resume_paused_state)

func _tutorial_target_control(target_key: String) -> Control:
	match target_key:
		"RoomPanel":
			return room_panel
		"PanelViralLoadGauge":
			return panel_vl_gauge
		"PanelAlertCountMatrix":
			return panel_alert_count_matrix
		"SensorCountdownCard":
			return get_node_or_null("Map/CanvasLayer/RoomPanel/MarginContainer/PanelVBox/SimulationStateCard/Margin/RootRow/SensorCountdownCard")
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
	# Re-apply after text/image updates so min-size expansion cannot push the bottom off-screen.
	_apply_overlay_card_sizing(false)
	_queue_overlay_card_reflow(false)

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
	if autoplay_mode_active:
		_autoplay_manual_next_card()
		return
	_tutorial_next_step()

func _on_tutorial_back_button_pressed() -> void:
	_tutorial_prev_step()

func _on_tutorial_skip_button_pressed() -> void:
	if autoplay_mode_active:
		_stop_autoplay_mode()
		return
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

	_hide_game_over()
	title_screen.hide()
	map.show()
	_clear_game_controls_overlay()
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
	room_alert_raw_count_total = 0
	room_alert_raw_count_by_room.clear()
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
	if autoplay_mode_active:
		_stop_autoplay_mode()
	_clear_game_controls_overlay()

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
	_set_brave_mode(false)
	_set_health_mode(false)
	map.hide()
	_show_game_over(reason)
	_update_room_panel(true)

func _on_save_object_button_pressed():
	object_file_dialog.show()

func _on_object_file_selected(file: String):
	object_file_dialog.hide()
	save_objects(file)

func _on_level_button_pressed() -> void:
	var levels: Array = difficulty_level_map.keys()
	levels.sort()
	var current_idx: int = levels.find(current_difficulty_level)
	if current_idx == -1:
		current_idx = levels.find("Standard")
		if current_idx == -1:
			current_idx = 0
	var next_idx: int = (current_idx + 1) % levels.size()
	current_difficulty_level = levels[next_idx]
	_update_level_button_display()
	_set_splash_version_override_from_config(_get_config_path_for_level(current_difficulty_level))
	if title_chart_payload_by_level.is_empty():
		_schedule_title_level_dependent_refresh()
		return
	_refresh_last_run_summary()
	_refresh_title_exposure_chart()
	_refresh_title_cost_chart()
	_refresh_title_alert_chart()

func _update_level_button_display() -> void:
	if level_label_large != null:
		level_label_large.text = current_difficulty_level

func _on_start_simulation_default_button_pressed():
	var config_path: String = _get_config_path_for_level(current_difficulty_level)
	_request_start_with_prompt(config_path)

func _on_start_autoplay_button_pressed() -> void:
	var config_path: String = _get_config_path_for_level(current_difficulty_level)
	_request_start_autoplay(config_path)

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
		"level": _normalized_level_name(current_difficulty_level),
		"player_name": Global.player_name,
		"run_number": Global.run_number,
		"run_id": Global.run_id,
		"end_reason": reason,
		"sim_speed_scale": Global.sim_speed_scale,
		"alert_trigger_count": room_alert_trigger_count_total,
		"raw_alert_count": room_alert_raw_count_total,
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
		splash_version = splash_version_label_value.strip_edges()
	if splash_version == "":
		splash_version = str(ProjectSettings.get_setting("application/config/splash_version_text", "")).strip_edges()
	if splash_version == "":
		splash_version = str(ProjectSettings.get_setting("application/config/version", "")).strip_edges()
	if splash_version == "":
		splash_version = "3.3"
	if splash_version.begins_with("v") or splash_version.begins_with("V"):
		splash_version = splash_version.substr(1).strip_edges()
	return splash_version

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
	var config_data: Dictionary = parsed_config
	return str(config_data.get("splash_version_text", config_data.get("version", ""))).strip_edges()

func _set_splash_version_override_from_config(config_path: String) -> void:
	splash_version_text_override = _config_splash_version_text(config_path)
	_update_splash_title_text()
	_update_splash_version_label()

func _update_splash_title_text() -> void:
	if title_label == null:
		return
	title_label.text = "BRAVE - Childcare\nSimulator Game"
	title_label.add_theme_color_override("font_color", Color("#0b2daf"))

func _update_splash_version_label() -> void:
	if version_label == null:
		return
	var version_text := _resolved_splash_version_text()
	version_label.text = "Version %s" % version_text

func _ready() -> void:
	_set_splash_version_override_from_config(_get_config_path_for_level(current_difficulty_level))
	_update_splash_version_label()
	object_file_dialog.file_selected.connect(_on_object_file_selected)
	config_file_dialog.file_selected.connect(_on_config_file_selected)

	save_object_button.pressed.connect(_on_save_object_button_pressed)
	start_simulation_button.pressed.connect(_on_start_simulation_button_pressed)
	start_simulation_default_button.pressed.connect(_on_start_simulation_default_button_pressed)
	if start_autoplay_button != null:
		start_autoplay_button.pressed.connect(_on_start_autoplay_button_pressed)
	tutorial_next_button.pressed.connect(_on_tutorial_next_button_pressed)
	tutorial_back_button.pressed.connect(_on_tutorial_back_button_pressed)
	tutorial_skip_button.pressed.connect(_on_tutorial_skip_button_pressed)
	end_simulation_button.pressed.connect(_on_end_simulation_button_pressed)
	player_name_input.text_changed.connect(_on_player_name_input_changed)
	if level_button != null:
		level_button.pressed.connect(_on_level_button_pressed)
		_update_level_button_display()
	if game_over_layer != null and game_over_layer.has_signal("continue_requested"):
		var continue_callable := Callable(self, "_on_game_over_continue_pressed")
		if not game_over_layer.is_connected("continue_requested", continue_callable):
			game_over_layer.connect("continue_requested", continue_callable)
	_hide_game_over()
	_update_player_name_labels()
	_refresh_title_level_dependent_data()
	_init_tutorial_ui()

	var home_dir = OS.get_environment("HOME")
	object_file_dialog.root_subfolder = home_dir
	config_file_dialog.root_subfolder = home_dir

	save_timer.timeout.connect(_on_save_timer_timeout)
	save_timer.wait_time = Global.save_every_s
	_update_title_screen_layout()
	get_viewport().size_changed.connect(_update_room_panel_layout)
	get_viewport().size_changed.connect(_update_title_screen_layout)
	get_viewport().size_changed.connect(_update_game_controls_overlay_layout)
	_init_room_panel_widgets()
	_update_game_controls_overlay_layout()
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
	if panel_brave_toggle_button != null:
		panel_brave_toggle_button.pressed.connect(_on_panel_brave_toggle_pressed)
	if panel_autoplay_toggle_button != null:
		panel_autoplay_toggle_button.pressed.connect(_on_panel_autoplay_toggle_pressed)
	if panel_speed_down_button != null:
		panel_speed_down_button.pressed.connect(_on_panel_speed_down_pressed)
	if panel_speed_up_button != null:
		panel_speed_up_button.pressed.connect(_on_panel_speed_up_pressed)
	if panel_pause_button != null:
		panel_pause_button.pressed.connect(_on_panel_pause_pressed)
	if panel_game_controls_button != null:
		panel_game_controls_button.pressed.connect(_on_panel_game_controls_pressed)
	_configure_side_panel_button_focus_behavior()
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
	if game_controls_overlay_active:
		if _is_game_controls_close_input(event):
			_set_game_controls_overlay(false)
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
		if Global.is_simulation_active and event.is_action_pressed("health_toggle") and not event.is_echo():
			_set_health_mode(not health_mode_active)
			get_viewport().set_input_as_handled()
			return
		if Global.is_simulation_active and event.is_action_pressed("brave_toggle") and not event.is_echo():
			_set_brave_mode(not brave_mode_active)
			get_viewport().set_input_as_handled()
			return
		get_viewport().set_input_as_handled()
		return

	if tutorial_mode_active:
		if event.is_action_pressed("tutorial_next") and not event.is_echo():
			_tutorial_next_step()
		elif event.is_action_pressed("tutorial_prev") and not event.is_echo():
			_tutorial_prev_step()
		elif event.is_action_pressed("tutorial_exit") and not event.is_echo():
			_end_tutorial_sequence()
		get_viewport().set_input_as_handled()
		return

	if autoplay_mode_active:
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

	if _is_question_mark_pressed(event):
		_toggle_game_controls_overlay()
		get_viewport().set_input_as_handled()
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
	var prior_state: bool = bool(room_alert_active.get(room_id, false))
	if not should_evaluate:
		var last_eval := float(room_alert_last_eval_s.get(room_id, -INF))
		if room_alert_check_interval_s <= 0.0 or now_s - last_eval >= room_alert_check_interval_s:
			should_evaluate = true

	if should_evaluate:
		var new_state: bool = room.viral_load >= room_alert_threshold_vl
		room_alert_active[room_id] = new_state
		if new_state:
			room_alert_raw_count_total += 1
			var raw_per_room_count: int = int(room_alert_raw_count_by_room.get(room_id, 0))
			var next_raw_per_room_count: int = raw_per_room_count + 1
			room_alert_raw_count_by_room[room_id] = next_raw_per_room_count
			if Global.room_save_file != null:
				var raw_room_name: String = room.display_name() if room.has_method("display_name") else _short_room_name(room.room_id)
				Global.room_save_file.store_line(JSON.stringify({
					"event": "room_alert_raw",
					"time": now_s,
					"timestamp": Time.get_datetime_string_from_system(),
					"room_name": raw_room_name,
					"room_id": room_id,
					"viral_load": room.viral_load,
					"threshold_vl": room_alert_threshold_vl,
					"raw_alert_count": room_alert_raw_count_total,
					"raw_alert_count_by_room": next_raw_per_room_count,
					"alert_trigger_count": room_alert_trigger_count_total,
					"alert_trigger_count_by_room": int(room_alert_trigger_count_by_room.get(room_id, 0)),
					"run_number": Global.run_number,
					"run_id": Global.run_id,
					"player_name": Global.player_name,
				}))
		if new_state and not prior_state:
			room_alert_trigger_count_total += 1
			var per_room_count: int = int(room_alert_trigger_count_by_room.get(room_id, 0))
			var next_per_room_count: int = per_room_count + 1
			room_alert_trigger_count_by_room[room_id] = next_per_room_count
			if Global.room_save_file != null:
				var room_name: String = room.display_name() if room.has_method("display_name") else _short_room_name(room.room_id)
				Global.room_save_file.store_line(JSON.stringify({
					"event": "room_alert",
					"time": now_s,
					"timestamp": Time.get_datetime_string_from_system(),
					"room_name": room_name,
					"room_id": room_id,
					"viral_load": room.viral_load,
					"threshold_vl": room_alert_threshold_vl,
					"alert_trigger_count": room_alert_trigger_count_total,
					"alert_trigger_count_by_room": next_per_room_count,
					"raw_alert_count": room_alert_raw_count_total,
					"raw_alert_count_by_room": int(room_alert_raw_count_by_room.get(room_id, 0)),
					"run_number": Global.run_number,
					"run_id": Global.run_id,
					"player_name": Global.player_name,
				}))
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
		_reflow_overlay_card_for_active_mode()
	if tutorial_mode_active:
		_tutorial_update_highlight()
	if autoplay_mode_active and not autoplay_current_card.is_empty():
		_overlay_update_highlight(autoplay_current_card)

	if not tutorial_mode_active and not autoplay_mode_active and Input.is_action_pressed("camera_right"):
		camera_2d.offset.x += 32
	if not tutorial_mode_active and not autoplay_mode_active and Input.is_action_pressed("camera_left"):
		camera_2d.offset.x -= 32
	if not tutorial_mode_active and not autoplay_mode_active and Input.is_action_pressed("camera_down"):
		camera_2d.offset.y += 32
	if not tutorial_mode_active and not autoplay_mode_active and Input.is_action_pressed("camera_up"):
		camera_2d.offset.y -= 32
	if not tutorial_mode_active and not autoplay_mode_active and Input.is_action_pressed("zoom_in"):
		camera_2d.zoom.x *= 1.05
		camera_2d.zoom.y *= 1.05
	if not tutorial_mode_active and not autoplay_mode_active and Input.is_action_pressed("zoom_out"):
		camera_2d.zoom.x *= 0.95
		camera_2d.zoom.y *= 0.95

	if autoplay_mode_active:
		_autoplay_tick()

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
