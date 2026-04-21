extends Control

@export var face_color: Color = Color("#1b2430")
@export var rim_color: Color = Color("#6f8397")
@export var tick_color: Color = Color("#9db0c3")
@export var minute_hand_color: Color = Color("#d9e6f2")
@export var hour_hand_color: Color = Color("#97c3ff")
@export var center_color: Color = Color("#f0f7ff")

var _time_seconds: float = 0.0

func set_time_seconds(value: float) -> void:
	_time_seconds = maxf(value, 0.0)
	queue_redraw()

func _draw() -> void:
	var center := size * 0.5
	var radius := minf(size.x, size.y) * 0.46
	if radius <= 2.0:
		return

	draw_circle(center, radius, face_color)
	draw_arc(center, radius, 0.0, TAU, 96, rim_color, 3.0)

	for i in range(60):
		var angle := -PI * 0.5 + TAU * (float(i) / 60.0)
		var is_hour := i % 5 == 0
		var outer := center + Vector2(cos(angle), sin(angle)) * (radius - 2.0)
		var inner_len := 11.0 if is_hour else 6.0
		var inner := center + Vector2(cos(angle), sin(angle)) * (radius - 2.0 - inner_len)
		draw_line(inner, outer, tick_color, 2.0 if is_hour else 1.0)

	var total_minutes := _time_seconds / 60.0
	var minute_in_hour := fmod(total_minutes, 60.0)
	var hours_total := _time_seconds / 3600.0
	var hour_on_clock := fmod(hours_total, 12.0)

	var minute_angle := -PI * 0.5 + TAU * (minute_in_hour / 60.0)
	var hour_angle := -PI * 0.5 + TAU * ((hour_on_clock + minute_in_hour / 60.0) / 12.0)

	var minute_tip := center + Vector2(cos(minute_angle), sin(minute_angle)) * (radius * 0.72)
	var hour_tip := center + Vector2(cos(hour_angle), sin(hour_angle)) * (radius * 0.52)

	draw_line(center, minute_tip, minute_hand_color, 3.0)
	draw_line(center, hour_tip, hour_hand_color, 5.0)
	draw_circle(center, 4.5, center_color)
