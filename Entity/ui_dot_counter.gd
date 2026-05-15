extends Control

@export var panel_color: Color = Color("#11171f")
@export var bezel_color: Color = Color("#3d4c5c")
@export var dot_on_color: Color = Color("#ffb347")
@export var dot_off_color: Color = Color("#2c3540")
@export var shadow_color: Color = Color(0, 0, 0, 0.35)
@export_range(1, 4, 1) var resolution_scale: int = 1
@export_range(0.75, 1.1, 0.01) var dot_spacing_scale: float = 1.0
@export_range(0.12, 0.45, 0.01) var dot_radius_scale: float = 0.23

var _value: int = 0

const DIGIT_PATTERNS := {
	"0": ["111", "101", "101", "101", "111"],
	"1": ["010", "110", "010", "010", "111"],
	"2": ["111", "001", "111", "100", "111"],
	"3": ["111", "001", "111", "001", "111"],
	"4": ["101", "101", "111", "001", "001"],
	"5": ["111", "100", "111", "001", "111"],
	"6": ["111", "100", "111", "101", "111"],
	"7": ["111", "001", "001", "001", "001"],
	"8": ["111", "101", "111", "101", "111"],
	"9": ["111", "101", "111", "001", "111"],
}

func set_value(value: int) -> void:
	_value = clampi(value, 0, 99)
	queue_redraw()

func _draw() -> void:
	if size.x <= 4.0 or size.y <= 4.0:
		return

	var outer := Rect2(Vector2.ZERO, size)
	draw_rect(Rect2(outer.position + Vector2(2, 3), outer.size), shadow_color, true)
	draw_rect(outer, bezel_color, true)

	var inner := outer.grow(-4.0)
	draw_rect(inner, panel_color, true)

	var digits := "%02d" % _value
	var scale: int = maxi(1, resolution_scale)
	var rows: int = 5 * scale
	var digit_columns: int = 3 * scale
	var gap_columns: int = scale
	var total_columns: int = digit_columns * 2 + gap_columns
	var pitch := minf(inner.size.x / float(total_columns + 1), inner.size.y / float(rows + 1))
	var spacing := pitch * dot_spacing_scale
	var radius := maxf(1.0, pitch * dot_radius_scale)
	var content_width := spacing * float(total_columns - 1)
	var content_height := spacing * float(rows - 1)
	var start := inner.position + Vector2((inner.size.x - content_width) * 0.5, (inner.size.y - content_height) * 0.5)

	for digit_idx in range(2):
		var pattern: Array = DIGIT_PATTERNS.get(digits[digit_idx], DIGIT_PATTERNS["0"])
		var col_offset: int = 0 if digit_idx == 0 else (digit_columns + gap_columns)
		for row in range(5):
			var row_bits: String = pattern[row]
			for col in range(3):
				var is_on := row_bits[col] == "1"
				for sy in range(scale):
					for sx in range(scale):
						var matrix_col: int = col_offset + col * scale + sx
						var matrix_row: int = row * scale + sy
						var point := start + Vector2(float(matrix_col) * spacing, float(matrix_row) * spacing)
						draw_circle(point, radius, dot_on_color if is_on else dot_off_color)
