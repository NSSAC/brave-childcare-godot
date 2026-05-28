extends Control

@export_enum("knob", "speedometer") var dial_style: String = "knob":
	set(value_new):
		dial_style = value_new
		queue_redraw()

@export var min_value: float = 0.0:
	set(value_new):
		min_value = value_new
		if max_value < min_value:
			max_value = min_value
		queue_redraw()

@export var max_value: float = 10.0:
	set(value_new):
		max_value = maxf(value_new, min_value)
		queue_redraw()

@export var value: float = 0.0:
	set(value_new):
		value = value_new
		queue_redraw()

@export var label_text: String = "":
	set(value_new):
		label_text = value_new
		queue_redraw()

@export var value_decimals: int = 1:
	set(value_new):
		value_decimals = maxi(value_new, 0)
		queue_redraw()

@export var accent_color: Color = Color("#5ca9ff"):
	set(value_new):
		accent_color = value_new
		queue_redraw()

@export var value_font_size: int = 24:
	set(value_new):
		value_font_size = maxi(value_new, 10)
		queue_redraw()

@export var label_font_size: int = 14:
	set(value_new):
		label_font_size = maxi(value_new, 8)
		queue_redraw()

@export var snap_display_to_step: bool = false:
	set(value_new):
		snap_display_to_step = value_new
		queue_redraw()

@export var snap_step: float = 1.0:
	set(value_new):
		snap_step = maxf(value_new, 0.001)
		queue_redraw()

func set_range(new_min: float, new_max: float) -> void:
	min_value = new_min
	max_value = new_max
	queue_redraw()

func set_current_value(new_value: float) -> void:
	value = new_value
	queue_redraw()

func set_style(new_style: String) -> void:
	dial_style = new_style
	queue_redraw()

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	if dial_style == "speedometer":
		_draw_speedometer()
	else:
		_draw_knob()

func _value_ratio() -> float:
	var span := maxf(max_value - min_value, 0.0001)
	return clampf((_display_value() - min_value) / span, 0.0, 1.0)

func _display_value() -> float:
	if not snap_display_to_step:
		return value
	var snapped: float = round((value - min_value) / snap_step) * snap_step + min_value
	return snapped

func _draw_knob() -> void:
	var size_v := size
	var center := size_v * 0.5
	var radius := minf(size_v.x, size_v.y) * 0.44
	var outer_ring_color := Color("#566678")
	var bezel_color := Color("#2b333d")
	var face_color := Color("#20272f")
	var inner_face_color := Color("#151b22")

	draw_circle(center, radius + 10.0, Color(0, 0, 0, 0.18))
	draw_circle(center, radius + 6.0, outer_ring_color)
	draw_circle(center, radius + 1.5, bezel_color)
	draw_circle(center, radius - 4.0, face_color)
	draw_circle(center, radius * 0.62, inner_face_color)
	draw_arc(center, radius + 2.0, deg_to_rad(135.0), deg_to_rad(405.0), 72, Color("#718294"), 3.0)

	var ratio := _value_ratio()
	var angle := deg_to_rad(135.0 + ratio * 270.0)
	var direction := Vector2(cos(angle), sin(angle))
	var pointer_outer := center + direction * (radius - 14.0)
	var pointer_inner := center + direction * (radius * 0.08)

	var slot_start := center - direction * (radius * 0.14)
	var slot_end := center + direction * (radius * 0.24)
	draw_line(slot_start, slot_end, Color("#35404b"), 13.0)
	draw_line(slot_start + Vector2(1.5, 1.5), slot_end + Vector2(1.5, 1.5), Color(0, 0, 0, 0.18), 13.0)
	draw_circle(center + direction * (radius * 0.18), radius * 0.08, Color("#26313b"))
	draw_circle(center + direction * (radius * 0.17), radius * 0.045, Color("#6e7d8c"))

	draw_line(pointer_inner, pointer_outer, accent_color, 10.0)
	draw_circle(center, radius * 0.16, Color("#a8b3bf"))
	draw_circle(center, radius * 0.09, Color("#6d7783"))

	var first_setting := maxi(int(ceil(min_value)), 1)
	var last_setting := mini(int(floor(max_value)), 9)
	var displayed_setting := int(round(_display_value()))
	var max_digit_position := Vector2.ZERO
	for setting in range(first_setting, last_setting + 1):
		var tick_ratio := (float(setting) - min_value) / maxf(max_value - min_value, 1.0)
		var dot_angle := deg_to_rad(135.0 + tick_ratio * 270.0)
		var dot_dir := Vector2(cos(dot_angle), sin(dot_angle))
		var dot_pos := center + dot_dir * (radius + 6.0)
		var digit_pos := center + dot_dir * (radius + 24.0)
		if setting == last_setting:
			max_digit_position = digit_pos
		var dot_color := accent_color.lightened(0.18) if setting == displayed_setting else Color("#8191a3")
		draw_circle(dot_pos, 3.2, dot_color)
		_draw_centered_label(digit_pos.x, digit_pos.y + 4.0, str(setting), Color("#8da0b3"), 10)

	if last_setting >= first_setting and displayed_setting >= last_setting:
		_draw_centered_label(max_digit_position.x, max_digit_position.y + 18.0, "MAX", accent_color.lightened(0.1), 11)

	_draw_centered_label(center.x, size_v.y -35.0, _formatted_value(), Color("#d6e2ee"), value_font_size)
	if label_text != "":
		_draw_centered_label(center.x, 150.0, label_text, Color("#95a7b8"), label_font_size)

func _draw_speedometer() -> void:
	var size_v := size
	var center := Vector2(size_v.x * 0.5, size_v.y * 0.78)
	var radius := minf(size_v.x * 0.42, size_v.y * 0.68)
	var start_deg := 150.0
	var end_deg := 390.0

	_draw_arc_segment(center, radius, start_deg, start_deg + 90.0, Color("#3e8f5c"), 8.0)
	_draw_arc_segment(center, radius, start_deg + 90.0, start_deg + 170.0, Color("#c9a84d"), 8.0)
	_draw_arc_segment(center, radius, start_deg + 170.0, end_deg, Color("#b64b4b"), 8.0)

	for i in range(13):
		var t := float(i) / 12.0
		var tick_deg := lerpf(start_deg, end_deg, t)
		var tick_angle := deg_to_rad(tick_deg)
		var outer := center + Vector2(cos(tick_angle), sin(tick_angle)) * (radius + 3.0)
		var inner := center + Vector2(cos(tick_angle), sin(tick_angle)) * (radius - (16.0 if i % 3 == 0 else 10.0))
		draw_line(inner, outer, Color("#9eb0c0"), 2.0)

	var ratio := _value_ratio()
	var needle_deg := lerpf(start_deg, end_deg, ratio)
	var needle_angle := deg_to_rad(needle_deg)
	var needle_tip := center + Vector2(cos(needle_angle), sin(needle_angle)) * (radius - 18.0)
	draw_line(center, needle_tip, accent_color, 4.0)
	draw_circle(center, 7.0, Color("#c9d5e3"))
	
	_draw_centered_label(center.x, size_v.y +6.0, _formatted_value(), Color("#d6e2ee"), value_font_size)
	if label_text != "":
		_draw_centered_label(center.x, 190.0, label_text, Color("#95a7b8"), label_font_size)

func _draw_arc_segment(center: Vector2, radius: float, start_deg: float, end_deg: float, color: Color, width: float) -> void:
	var points := PackedVector2Array()
	var steps := 28
	for i in range(steps + 1):
		var t := float(i) / float(steps)
		var a := deg_to_rad(lerpf(start_deg, end_deg, t))
		points.append(center + Vector2(cos(a), sin(a)) * radius)
	draw_polyline(points, color, width, true)

func _formatted_value() -> String:
	return "%.*f" % [value_decimals, _display_value()]

func _draw_centered_label(x: float, y: float, text_value: String, color: Color, font_size: int) -> void:
	var font := ThemeDB.fallback_font
	if font == null:
		return
	var str_size := font.get_string_size(text_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var pos := Vector2(x - str_size.x * 0.5, y)
	draw_string(font, pos, text_value, HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size, color)
