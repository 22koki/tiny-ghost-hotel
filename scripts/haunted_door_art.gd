extends Control

@export var mirrored: bool = false

const WOOD_DARK := Color(0.055, 0.018, 0.022, 1.0)
const WOOD_MID := Color(0.17, 0.045, 0.028, 1.0)
const WOOD_LIGHT := Color(0.30, 0.095, 0.050, 1.0)
const IRON := Color(0.035, 0.030, 0.045, 1.0)
const IRON_EDGE := Color(0.29, 0.23, 0.20, 1.0)
const BRASS := Color(0.68, 0.40, 0.15, 1.0)
const BLOOD := Color(0.55, 0.018, 0.035, 0.82)

func _ready() -> void:
	resized.connect(queue_redraw)
	queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	if w < 10.0 or h < 10.0:
		return

	draw_rect(Rect2(15, 12, w - 30, h - 24), IRON)
	draw_rect(Rect2(23, 20, w - 46, h - 40), WOOD_DARK)
	draw_rect(Rect2(31, 28, w - 62, h - 56), WOOD_MID)

	for plank in range(1, 10):
		var x := w * float(plank) / 10.0
		var grain := Color(0.42, 0.15, 0.07, 0.23) if plank % 2 == 0 else Color(0.025, 0.008, 0.014, 0.38)
		draw_line(Vector2(x, 38), Vector2(x + sin(float(plank) * 1.7) * 5.0, h - 38), grain, 2.0, true)

	_draw_gothic_panel(Rect2(w * 0.14, h * 0.13, w * 0.72, h * 0.32))
	_draw_gothic_panel(Rect2(w * 0.18, h * 0.53, w * 0.64, h * 0.34))
	_draw_iron_band(58.0, w)
	_draw_iron_band(h - 76.0, w)
	_draw_rivets(w, h)
	_draw_haunted_crest(Vector2(w * 0.5, h * 0.34))
	_draw_knocker(w, h)

func _draw_gothic_panel(rect: Rect2) -> void:
	var x := rect.position.x
	var y := rect.position.y
	var w := rect.size.x
	var h := rect.size.y
	var arch := w * 0.20
	var points := PackedVector2Array([
		Vector2(x, y + arch),
		Vector2(x + arch * 0.35, y + arch * 0.32),
		Vector2(x + w * 0.5, y),
		Vector2(x + w - arch * 0.35, y + arch * 0.32),
		Vector2(x + w, y + arch),
		Vector2(x + w, y + h),
		Vector2(x, y + h)
	])
	draw_colored_polygon(points, IRON)
	var inner := PackedVector2Array([
		Vector2(x + 7, y + arch + 6),
		Vector2(x + arch * 0.48, y + arch * 0.45),
		Vector2(x + w * 0.5, y + 10),
		Vector2(x + w - arch * 0.48, y + arch * 0.45),
		Vector2(x + w - 7, y + arch + 6),
		Vector2(x + w - 7, y + h - 7),
		Vector2(x + 7, y + h - 7)
	])
	draw_colored_polygon(inner, WOOD_LIGHT)
	var inset := PackedVector2Array([
		Vector2(x + 18, y + arch + 16),
		Vector2(x + arch * 0.70, y + arch * 0.63),
		Vector2(x + w * 0.5, y + 23),
		Vector2(x + w - arch * 0.70, y + arch * 0.63),
		Vector2(x + w - 18, y + arch + 16),
		Vector2(x + w - 18, y + h - 18),
		Vector2(x + 18, y + h - 18)
	])
	draw_colored_polygon(inset, WOOD_DARK)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_polyline(outline, BRASS.darkened(0.28), 2.0, true)
	draw_line(Vector2(x + 21, y + h - 22), Vector2(x + w - 21, y + h - 22), Color(0.66, 0.31, 0.12, 0.6), 1.5, true)

func _draw_iron_band(y: float, w: float) -> void:
	draw_rect(Rect2(31, y, w - 62, 12), IRON)
	draw_line(Vector2(34, y + 2), Vector2(w - 34, y + 2), IRON_EDGE, 1.5, true)
	draw_line(Vector2(34, y + 10), Vector2(w - 34, y + 10), Color(0.012, 0.008, 0.016, 1), 1.5, true)

func _draw_rivets(w: float, h: float) -> void:
	for y in [72.0, h - 70.0]:
		for x in range(48, int(w) - 32, 64):
			draw_circle(Vector2(float(x), y), 4.2, Color(0.012, 0.010, 0.018, 1))
			draw_circle(Vector2(float(x) - 1.0, y - 1.0), 1.4, IRON_EDGE)

func _draw_haunted_crest(center: Vector2) -> void:
	draw_arc(center, 31.0, 0.0, TAU, 48, BRASS.darkened(0.30), 2.0, true)
	draw_arc(center, 23.0, 0.0, TAU, 48, Color(0.46, 0.10, 0.08, 0.9), 1.4, true)
	draw_line(center + Vector2(-17, 0), center + Vector2(17, 0), IRON_EDGE, 2.0, true)
	draw_circle(center + Vector2(0, -1), 8.0, BLOOD)
	draw_circle(center + Vector2(0, -1), 3.0, Color(1.0, 0.18, 0.08, 0.95))
	draw_line(center + Vector2(-12, 13), center + Vector2(0, 21), BRASS.darkened(0.25), 1.5, true)
	draw_line(center + Vector2(0, 21), center + Vector2(12, 13), BRASS.darkened(0.25), 1.5, true)

func _draw_knocker(w: float, h: float) -> void:
	var x := 105.0 if mirrored else w - 105.0
	var center := Vector2(x, h * 0.55)
	draw_circle(center, 34.0, IRON)
	draw_arc(center, 27.0, 0.0, TAU, 48, BRASS, 2.5, true)
	draw_arc(center + Vector2(0, 7), 15.0, PI, TAU, 36, IRON_EDGE, 4.0, true)
	draw_circle(center + Vector2(0, -14), 6.0, BRASS.darkened(0.18))
	draw_circle(center + Vector2(-3, -15), 1.5, Color(1.0, 0.78, 0.42, 1.0))
