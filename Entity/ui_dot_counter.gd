extends Control

@export var panel_color: Color = Color("#11171f")
@export var bezel_color: Color = Color("#3d4c5c")
@export var dot_on_color: Color = Color("#ffb347")
@export var dot_off_color: Color = Color("#2c3540")
@export var shadow_color: Color = Color(0, 0, 0, 0.35)

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
	var rows := 5
	var total_columns := 7 # 3 columns per digit + 1 gap
	var pitch := minf(inner.size.x / float(total_columns + 1), inner.size.y / float(rows + 1))
	var radius := maxf(1.6, pitch * 0.28)
	var content_width := pitch * float(total_columns - 1)
	var content_height := pitch * float(rows - 1)
	var start := inner.position + Vector2((inner.size.x - content_width) * 0.5, (inner.size.y - content_height) * 0.5)

	for digit_idx in range(2):
		var pattern: Array = DIGIT_PATTERNS.get(digits[digit_idx], DIGIT_PATTERNS["0"])
		var col_offset := 0 if digit_idx == 0 else 4
		for row in range(rows):
			var row_bits: String = pattern[row]
			for col in range(3):
				var is_on := row_bits[col] == "1"
				var point := start + Vector2(float(col_offset + col) * pitch, float(row) * pitch)
				draw_circle(point, radius, dot_on_color if is_on else dot_off_color)
