extends Control

@export var axis_color: Color = Color("#7f93a8")
@export var grid_color: Color = Color(0.55, 0.64, 0.74, 0.22)
@export var label_color: Color = Color("#c9d8e6")
@export var plot_background_color: Color = Color(0.08, 0.12, 0.18, 0.92)
@export var line_width: float = 2.4
@export var min_plot_height: float = 120.0
@export var reveal_duration_s: float = 6.0
@export var animate_on_set_series: bool = true
@export var show_x_axis_labels: bool = true
@export var chart_start_time_s: float = 7.0 * 3600.0
@export var chart_end_time_s: float = 18 * 3600.0
const LEGEND_LABEL_MAX_WIDTH: float = 220.0

var _series: Array[Dictionary] = []
var _status_text: String = ""
var _reveal_t: float = 1.0:
	set(value):
		_reveal_t = value
		queue_redraw()
var _reveal_tween: Tween

func _draw_series_line(series: Dictionary, min_t: float, max_t: float, min_y: float, max_y: float, plot_rect: Rect2) -> void:
	var pts_variant: Variant = series.get("points", [])
	if not (pts_variant is Array):
		return
	var points: Array = pts_variant
	if points.size() < 2:
		return

	var color: Color = _to_color(series.get("color", Color("#7cc3ff")))
	var line_points: PackedVector2Array = _build_revealed_polyline(points, min_t, max_t, min_y, max_y, plot_rect)
	if line_points.size() >= 2:
		draw_polyline(line_points, color, line_width, true)

func set_series(series: Array[Dictionary], status_text: String = "") -> void:
	_series = series
	_status_text = status_text
	if _reveal_tween != null and _reveal_tween.is_running():
		_reveal_tween.kill()
	if animate_on_set_series and reveal_duration_s > 0.0 and _series.size() > 0:
		_reveal_t = 0.0
		_reveal_tween = create_tween()
		_reveal_tween.tween_property(self, "_reveal_t", 1.0, reveal_duration_s).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	else:
		_reveal_t = 1.0
	queue_redraw()

func _draw() -> void:
	var size_rect: Vector2 = size
	if size_rect.x < 120.0 or size_rect.y < min_plot_height:
		return

	var margin_left := 62.0
	var margin_right := 14.0
	var margin_top := 14.0
	var margin_bottom := 32.0
	var plot_rect := Rect2(
		margin_left,
		margin_top,
		max(1.0, size_rect.x - margin_left - margin_right),
		max(1.0, size_rect.y - margin_top - margin_bottom)
	)

	draw_rect(plot_rect, plot_background_color, true)
	draw_rect(plot_rect, axis_color, false, 1.2)

	if _series.is_empty():
		_draw_text_centered(plot_rect, "No data", label_color)
		return

	var domain: Dictionary = _compute_domain(_series)
	var min_t: float = domain["min_t"]
	var max_t: float = domain["max_t"]
	var min_y: float = domain["min_y"]
	var max_y: float = domain["max_y"]

	if max_t <= min_t:
		max_t = min_t + 1.0
	if max_y <= min_y:
		max_y = min_y + 1.0

	_draw_hour_grid(plot_rect, min_t, max_t)
	_draw_y_grid(plot_rect, min_y, max_y)

	for series in _series:
		var label_text: String = str(series.get("label", ""))
		var is_latest: bool = bool(series.get("is_latest", false)) or label_text.begins_with("Latest:")
		if is_latest:
			continue
		_draw_series_line(series, min_t, max_t, min_y, max_y, plot_rect)

	for series in _series:
		var label_text: String = str(series.get("label", ""))
		var is_latest: bool = bool(series.get("is_latest", false)) or label_text.begins_with("Latest:")
		if not is_latest:
			continue
		_draw_series_line(series, min_t, max_t, min_y, max_y, plot_rect)

	_draw_axes(plot_rect)
	_draw_legend(plot_rect)
	if _status_text != "":
		draw_string(
			ThemeDB.fallback_font,
			Vector2(plot_rect.position.x, size_rect.y - 8.0),
			_status_text,
			HORIZONTAL_ALIGNMENT_LEFT,
			plot_rect.size.x,
			12,
			Color(0.72, 0.8, 0.88, 0.9)
		)

func _compute_domain(series: Array[Dictionary]) -> Dictionary:
	var min_t: float = INF
	var max_t: float = -INF
	var min_y: float = INF
	var max_y: float = -INF

	for entry in series:
		var pts_variant: Variant = entry.get("points", [])
		if not (pts_variant is Array):
			continue
		for point in (pts_variant as Array):
			if not (point is Dictionary):
				continue
			var row := point as Dictionary
			var t := float(row.get("time", 0.0))
			var y := float(row.get("value", 0.0))
			min_t = min(min_t, t)
			max_t = max(max_t, t)
			min_y = min(min_y, y)
			max_y = max(max_y, y)

	if not is_finite(min_t):
		min_t = 0.0
		max_t = 1.0
	if not is_finite(min_y):
		min_y = 0.0
		max_y = 1.0

	var y_span: float = max(1.0, max_y - min_y)
	max_y += y_span * 0.08
	min_y = max(0.0, min_y - y_span * 0.03)
	var nice_y: Dictionary = _nice_axis_bounds(min_y, max_y, 5)
	min_y = float(nice_y["min"])
	max_y = float(nice_y["max"])
	min_t = chart_start_time_s
	max_t = chart_end_time_s

	return {
		"min_t": min_t,
		"max_t": max_t,
		"min_y": min_y,
		"max_y": max_y,
	}

func _draw_hour_grid(plot_rect: Rect2, min_t: float, max_t: float) -> void:
	var hour_start := int(floor(min_t / 3600.0))
	var hour_end := int(floor(max_t / 3600.0))
	if hour_end <= hour_start:
		hour_end = hour_start + 1

	for h in range(hour_start, hour_end + 1):
		var t := float(h) * 3600.0
		var x := _remap(t, min_t, max_t, plot_rect.position.x, plot_rect.end.x)
		draw_line(Vector2(x, plot_rect.position.y), Vector2(x, plot_rect.end.y), grid_color, 1.0)
		if show_x_axis_labels:
			draw_string(
				ThemeDB.fallback_font,
				Vector2(x - 14.0, plot_rect.end.y + 16.0),
				"%02d:00" % posmod(h, 24),
				HORIZONTAL_ALIGNMENT_LEFT,
				80.0,
				12,
				label_color
			)

	if not is_equal_approx(fmod(max_t, 3600.0), 0.0):
		var final_x: float = _remap(max_t, min_t, max_t, plot_rect.position.x, plot_rect.end.x)
		draw_line(Vector2(final_x, plot_rect.position.y), Vector2(final_x, plot_rect.end.y), grid_color, 1.0)
		if show_x_axis_labels:
			draw_string(
				ThemeDB.fallback_font,
				Vector2(final_x - 18.0, plot_rect.end.y + 16.0),
				_seconds_to_clock_label(max_t),
				HORIZONTAL_ALIGNMENT_LEFT,
				80.0,
				12,
				label_color
			)

func _draw_y_grid(plot_rect: Rect2, min_y: float, max_y: float) -> void:
	var axis: Dictionary = _nice_axis_bounds(min_y, max_y, 5)
	var tick_min: float = float(axis["min"])
	var tick_max: float = float(axis["max"])
	var tick_step: float = float(axis["step"])
	var tick_value: float = tick_min
	while tick_value <= tick_max + tick_step * 0.5:
		var y := _remap(tick_value, tick_min, tick_max, plot_rect.end.y, plot_rect.position.y)
		draw_line(Vector2(plot_rect.position.x, y), Vector2(plot_rect.end.x, y), grid_color, 1.0)
		draw_string(
			ThemeDB.fallback_font,
			Vector2(4.0, y + 4.0),
			_format_compact_number(tick_value),
			HORIZONTAL_ALIGNMENT_LEFT,
			64.0,
			12,
			label_color
		)
		tick_value += tick_step

func _draw_axes(plot_rect: Rect2) -> void:
	draw_line(Vector2(plot_rect.position.x, plot_rect.position.y), Vector2(plot_rect.position.x, plot_rect.end.y), axis_color, 1.4)
	draw_line(Vector2(plot_rect.position.x, plot_rect.end.y), Vector2(plot_rect.end.x, plot_rect.end.y), axis_color, 1.4)

func _draw_legend(plot_rect: Rect2) -> void:
	var y := plot_rect.position.y + 14.0
	var x := plot_rect.position.x + 10.0
	for series in _series:
		var label: String = str(series.get("label", "run"))
		var color: Color = _to_color(series.get("color", Color("#7cc3ff")))
		draw_line(Vector2(x, y), Vector2(x + 16.0, y), color, max(2.0, line_width + 0.6))
		draw_string(ThemeDB.fallback_font, Vector2(x + 22.0, y + 4.0), label, HORIZONTAL_ALIGNMENT_LEFT, LEGEND_LABEL_MAX_WIDTH, 12, label_color)
		y += 18.0

func _build_revealed_polyline(points: Array, min_t: float, max_t: float, min_y: float, max_y: float, plot_rect: Rect2) -> PackedVector2Array:
	var revealed_points := PackedVector2Array()
	var reveal_time: float = lerpf(min_t, max_t, clampf(_reveal_t, 0.0, 1.0))
	var prev_time: float = -INF
	var prev_value: float = 0.0
	var prev_added: bool = false
	var has_prev_raw: bool = false

	for raw_point in points:
		if not (raw_point is Dictionary):
			continue
		var point: Dictionary = raw_point
		var raw_t: float = float(point.get("time", 0.0))
		var y: float = float(point.get("value", 0.0))

		if has_prev_raw and raw_t < min_t and prev_time < min_t:
			prev_time = raw_t
			prev_value = y
			continue

		# Stop at chart_end_time_s: interpolate to the boundary and break.
		if raw_t > max_t:
			if prev_added and is_finite(prev_time) and raw_t > prev_time:
				var ratio: float = clampf((max_t - prev_time) / (raw_t - prev_time), 0.0, 1.0)
				var y_at_end: float = lerpf(prev_value, y, ratio)
				revealed_points.push_back(Vector2(
					plot_rect.end.x,
					_remap(y_at_end, min_y, max_y, plot_rect.end.y, plot_rect.position.y)
				))
			break

		var t: float = clampf(raw_t, min_t, max_t)

		if t <= reveal_time:
			revealed_points.push_back(Vector2(
				_remap(t, min_t, max_t, plot_rect.position.x, plot_rect.end.x),
				_remap(y, min_y, max_y, plot_rect.end.y, plot_rect.position.y)
			))
			prev_added = true
		else:
			if prev_added and is_finite(prev_time) and t > prev_time:
				var ratio: float = (reveal_time - prev_time) / (t - prev_time)
				ratio = clampf(ratio, 0.0, 1.0)
				var y_interp: float = lerpf(prev_value, y, ratio)
				revealed_points.push_back(Vector2(
					_remap(reveal_time, min_t, max_t, plot_rect.position.x, plot_rect.end.x),
					_remap(y_interp, min_y, max_y, plot_rect.end.y, plot_rect.position.y)
				))
			break

		has_prev_raw = true
		prev_time = t
		prev_value = y

	return revealed_points

func _draw_text_centered(rect: Rect2, text_value: String, color: Color) -> void:
	draw_string(
		ThemeDB.fallback_font,
		Vector2(rect.position.x + 8.0, rect.position.y + rect.size.y * 0.55),
		text_value,
		HORIZONTAL_ALIGNMENT_CENTER,
		rect.size.x - 16.0,
		14,
		color
	)

func _remap(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	if is_equal_approx(in_min, in_max):
		return out_min
	return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)

func _to_color(value: Variant) -> Color:
	if value is Color:
		return value
	if value is String:
		return Color(str(value))
	return Color("#7cc3ff")

func _seconds_to_clock_label(total_seconds: float) -> String:
	var rounded_seconds: int = int(round(total_seconds))
	var hours: int = (rounded_seconds / 3600) % 24
	var minutes: int = (rounded_seconds % 3600) / 60
	return "%02d:%02d" % [hours, minutes]

func _nice_axis_bounds(min_value: float, max_value: float, target_ticks: int) -> Dictionary:
	var safe_target_ticks: int = max(1, target_ticks)
	var span: float = max(1.0, max_value - min_value)
	var step: float = _nice_step(span / float(safe_target_ticks))
	var rounded_min: float = floor(min_value / step) * step
	var rounded_max: float = ceil(max_value / step) * step
	if rounded_min < 0.0 and min_value >= 0.0:
		rounded_min = 0.0
	return {
		"min": rounded_min,
		"max": rounded_max,
		"step": step,
	}

func _nice_step(raw_step: float) -> float:
	if raw_step <= 0.0:
		return 1.0
	var magnitude: float = pow(10.0, floor(log(raw_step) / log(10.0)))
	var residual: float = raw_step / magnitude
	if residual <= 1.0:
		return 1.0 * magnitude
	if residual <= 2.0:
		return 2.0 * magnitude
	if residual <= 5.0:
		return 5.0 * magnitude
	return 10.0 * magnitude

func _format_compact_number(value: float) -> String:
	var abs_value: float = absf(value)
	if abs_value >= 1000000.0:
		return "%.1fM" % (value / 1000000.0)
	if abs_value >= 1000.0:
		return "%.1fK" % (value / 1000.0)
	if abs_value >= 100.0:
		return "%.0f" % value
	if abs_value >= 10.0:
		return "%.1f" % value
	return "%.2f" % value
