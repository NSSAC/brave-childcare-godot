extends CanvasLayer

signal continue_requested

const AUTO_RETURN_DURATION_S: float = 15.0
const UP_CONFETTI_GAP_RATIO: float = 0.15
const UP_CONFETTI_GAP_MIN_PX: float = 4.0
const UP_CONFETTI_GAP_MAX_PX: float = 10.0
const AWARD_ART_BY_MEDAL := {
	"Bioareosol Buster": "res://Art/award_BioaerosolBuster.png",
	"HVAC Hero": "res://Art/award_HVAC_hero.png",
	"Aerosol Avenger": "res://Art/award_Aerosol_Avenger.png",
	"Clean Air Crafter": "res://Art/award_cleanair_crafter.png",
}

@onready var subtitle_label: Label = %GameOverSubtitleLabel
@onready var medal_label: Label = %GameOverMedalLabel
@onready var summary_label: Label = %GameOverSummaryLabel
@onready var award_art: TextureRect = %GameOverAwardArt
@onready var exposure_status_label: Label = %GameOverExposureStatusLabel
@onready var cost_status_label: Label = %GameOverCostStatusLabel
@onready var alert_status_label: Label = %GameOverAlertStatusLabel
@onready var exposure_chart: Control = %GameOverExposureChart
@onready var cost_chart: Control = %GameOverCostChart
@onready var alert_chart: Control = %GameOverAlertChart
@onready var continue_button: Button = %GameOverContinueButton
@onready var return_progress: ProgressBar = %GameOverReturnProgress
@onready var stay_button: Button = %GameOverStayButton
@onready var card: Control = $Center/Card
@onready var confetti_particles_up: GPUParticles2D = $"ConfettiParticles Up"
@onready var confetti_particles_rain: GPUParticles2D = $"ConfettiParticles Rain"

var _auto_return_elapsed_s: float = 0.0
var _auto_return_enabled: bool = false

### Confetti effects inspired by: https://gist.github.com/benmccown/52eb2d9b0a2899fe4d6d6aea6514eafb

func _ready() -> void:
	if continue_button != null:
		continue_button.pressed.connect(_on_continue_pressed)
	if stay_button != null:
		stay_button.pressed.connect(_on_stay_pressed)
	if get_viewport() != null:
		get_viewport().size_changed.connect(_on_viewport_size_changed)
	call_deferred("_refresh_confetti_layout")
	set_process(true)

func show_results(data: Dictionary) -> void:
	visible = true
	_auto_return_elapsed_s = 0.0
	_auto_return_enabled = true
	call_deferred("_refresh_confetti_layout")
	_trigger_confetti()
	if subtitle_label != null:
		subtitle_label.text = str(data.get("subtitle", "Great work today!"))
	var medal_name: String = str(data.get("medal", "Playroom Pal"))
	if medal_label != null:
		medal_label.text = medal_name
		medal_label.add_theme_color_override("font_color", _as_color(data.get("medal_color", Color("#ffd36b"))))
	_update_award_art(medal_name)
	if summary_label != null:
		summary_label.text = str(data.get("summary", ""))

	var exposure_series: Array[Dictionary] = data.get("exposure_series", [])
	var exposure_status: String = str(data.get("exposure_status", ""))
	if exposure_chart != null and exposure_chart.has_method("set_series"):
		exposure_chart.call("set_series", exposure_series, "")
	if exposure_status_label != null:
		exposure_status_label.text = exposure_status

	var cost_series: Array[Dictionary] = data.get("cost_series", [])
	var cost_status: String = str(data.get("cost_status", ""))
	if cost_chart != null and cost_chart.has_method("set_series"):
		cost_chart.call("set_series", cost_series, "")
	if cost_status_label != null:
		cost_status_label.text = cost_status

	var alert_series: Array[Dictionary] = data.get("alert_series", [])
	var alert_status: String = str(data.get("alert_status", ""))
	if alert_chart != null and alert_chart.has_method("set_series"):
		alert_chart.call("set_series", alert_series, "")
	if alert_status_label != null:
		alert_status_label.text = alert_status
	if stay_button != null:
		stay_button.disabled = false
		stay_button.text = "Stay"
	_update_return_button_ui()

func hide_layer() -> void:
	visible = false
	_auto_return_enabled = false
	_auto_return_elapsed_s = 0.0
	_update_return_button_ui()
	_stop_confetti()

func _trigger_confetti() -> void:
	_refresh_confetti_layout()
	if confetti_particles_up != null:
		confetti_particles_up.emitting = true
	if confetti_particles_rain != null:
		confetti_particles_rain.emitting = true

func _stop_confetti() -> void:
	if confetti_particles_up != null:
		confetti_particles_up.emitting = false
	if confetti_particles_rain != null:
		confetti_particles_rain.emitting = false

func _process(delta: float) -> void:
	if not visible or not _auto_return_enabled:
		return
	_auto_return_elapsed_s = minf(_auto_return_elapsed_s + delta, AUTO_RETURN_DURATION_S)
	_update_return_button_ui()
	if _auto_return_elapsed_s >= AUTO_RETURN_DURATION_S:
		_auto_return_enabled = false
		emit_signal("continue_requested")

func _on_continue_pressed() -> void:
	emit_signal("continue_requested")

func _on_stay_pressed() -> void:
	_auto_return_enabled = false
	_update_return_button_ui()
	if stay_button != null:
		stay_button.disabled = true
		stay_button.text = "Timer Paused"

func _on_viewport_size_changed() -> void:
	call_deferred("_refresh_confetti_layout")

func _refresh_confetti_layout() -> void:
	var viewport := get_viewport()
	if viewport == null:
		return
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	_refresh_up_confetti_layout(viewport_size)
	_refresh_rain_confetti_layout(viewport_size)

func _refresh_up_confetti_layout(viewport_size: Vector2) -> void:
	if confetti_particles_up == null or card == null:
		return
	var card_rect: Rect2 = card.get_global_rect()
	var card_center_x: float = card_rect.position.x + (card_rect.size.x * 0.5)
	var vertical_gap: float = clampf(viewport_size.y * UP_CONFETTI_GAP_RATIO, UP_CONFETTI_GAP_MIN_PX, UP_CONFETTI_GAP_MAX_PX)
	confetti_particles_up.position = Vector2(card_center_x, maxf(0.0, card_rect.position.y - vertical_gap))
	var up_material := confetti_particles_up.process_material as ParticleProcessMaterial
	if up_material != null:
		var half_width: float = clampf(card_rect.size.x * 0.3, 140.0, viewport_size.x * 0.5)
		var half_height: float = clampf(card_rect.size.y * 0.03, 18.0, 36.0)
		up_material.emission_box_extents = Vector3(half_width, half_height, 1.0)

func _refresh_rain_confetti_layout(viewport_size: Vector2) -> void:
	if confetti_particles_rain == null:
		return
	confetti_particles_rain.position = Vector2(viewport_size.x * 0.5, 0.0)
	var rain_material := confetti_particles_rain.process_material as ParticleProcessMaterial
	if rain_material != null:
		rain_material.emission_box_extents = Vector3(viewport_size.x * 0.5, maxf(6.0, viewport_size.y * 0.012), 1.0)

func _update_return_button_ui() -> void:
	var ratio: float = 0.0
	if AUTO_RETURN_DURATION_S > 0.0:
		ratio = clampf(_auto_return_elapsed_s / AUTO_RETURN_DURATION_S, 0.0, 1.0)
	if return_progress != null:
		return_progress.value = ratio * 100.0
	if continue_button != null:
		if _auto_return_enabled:
			var remaining_s: int = int(ceili(AUTO_RETURN_DURATION_S - _auto_return_elapsed_s))
			continue_button.text = "Return to Title Screen (%ds)" % remaining_s
		else:
			continue_button.text = "Return to Title Screen"

func _update_award_art(medal_name: String) -> void:
	if award_art == null:
		return
	var art_path: String = str(AWARD_ART_BY_MEDAL.get(medal_name, "res://Art/BRAVE_icon.png"))
	var texture: Texture2D = load(art_path)
	if texture == null:
		texture = load("res://Art/BRAVE_icon.png")
	award_art.texture = texture

func _as_color(value: Variant) -> Color:
	if value is Color:
		return value
	if value is String:
		return Color(str(value))
	return Color("#ffd36b")
