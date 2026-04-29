extends Control

@export var face_color: Color = Color("#ffffff")
@export var bezel_outer_color: Color = Color("#7a5a3a")
@export var rim_color: Color = Color("#1f1f1f")
@export var tick_color: Color = Color("#1f1f1f")
@export var numeral_color: Color = Color("#1f1f1f")
@export var minute_hand_color: Color = Color("#111111")
@export var hour_hand_color: Color = Color("#111111")
@export var center_color: Color = Color("#111111")

var _time_seconds: float = 0.0

func set_time_seconds(value: float) -> void:
	_time_seconds = maxf(value, 0.0)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.46
	if radius <= 2.0:
		return

	draw_circle(center, radius, bezel_outer_color)
	draw_circle(center, radius - 5.0, face_color)
	draw_arc(center, radius - 5.0, 0.0, TAU, 96, rim_color, 2.6)
	draw_arc(center, radius - 8.0, 0.0, TAU, 96, Color(rim_color, 0.22), 1.0)

	# Classic hour ticks.
	for i in range(12):
		if i == 0 or i == 3 or i == 6 or i == 9:
			continue
		var angle := -PI * 0.5 + TAU * (float(i) / 12.0)
		var outer := center + Vector2(cos(angle), sin(angle)) * (radius - 11.0)
		var inner := center + Vector2(cos(angle), sin(angle)) * (radius - 21.5)
		draw_line(inner, outer, tick_color, 2.6)

	# Four primary numerals: 12, 3, 6, 9.
	var font: Font = get_theme_default_font()
	var numeral_font_size: int = int(clampf(round(radius * 0.33), 11.0, 19.0))
	if font != null:
		var numerals := [
			{"text": "12", "angle": -PI * 0.5},
			{"text": "3", "angle": 0.0},
			{"text": "6", "angle": PI * 0.5},
			{"text": "9", "angle": PI},
		]
		for item in numerals:
			var label_text: String = item["text"]
			var angle: float = item["angle"]
			var text_size := font.get_string_size(label_text, HORIZONTAL_ALIGNMENT_LEFT, -1, numeral_font_size)
			var label_center := center + Vector2(cos(angle), sin(angle)) * (radius * 0.70)
			var label_pos := label_center - Vector2(text_size.x * 0.5, -text_size.y * 0.35)
			_draw_heavy_string(font, label_pos, label_text, numeral_font_size, numeral_color)

	var total_minutes := _time_seconds / 60.0
	var minute_in_hour := fmod(total_minutes, 60.0)
	# Use integer hour plus minute fraction to avoid double-counting minutes.
	var hour_on_clock := fmod(floor(_time_seconds / 3600.0), 12.0)

	var minute_angle := -PI * 0.5 + TAU * (minute_in_hour / 60.0)
	var hour_angle := -PI * 0.5 + TAU * ((hour_on_clock + minute_in_hour / 60.0) / 12.0)

	_draw_tapered_hand(center, hour_angle, radius * 0.50, 5.8, 2.2, hour_hand_color)
	_draw_tapered_hand(center, minute_angle, radius * 0.72, 4.2, 1.4, minute_hand_color)
	draw_circle(center, 3.4, center_color)

func _draw_tapered_hand(center: Vector2, angle: float, length: float, base_width: float, tip_width: float, color: Color) -> void:
	var dir := Vector2(cos(angle), sin(angle))
	var perp := Vector2(-dir.y, dir.x)
	var base := center - dir * 2.0
	var tip := center + dir * length
	var points := PackedVector2Array([
		base + perp * (base_width * 0.5),
		base - perp * (base_width * 0.5),
		tip - perp * (tip_width * 0.5),
		tip + perp * (tip_width * 0.5),
	])
	draw_colored_polygon(points, color)

func _draw_heavy_string(font: Font, position: Vector2, text: String, font_size: int, color: Color) -> void:
	# Draw with tiny offsets to emulate a heavier school-clock numeral.
	var offsets := [
		Vector2.ZERO,
		Vector2(0.45, 0.0),
		Vector2(-0.45, 0.0),
		Vector2(0.0, 0.45),
		Vector2(0.0, -0.45),
	]
	for offset in offsets:
		draw_string(font, position + offset, text, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
