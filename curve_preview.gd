@tool
extends Control

@export var trans_type: Tween.TransitionType = Tween.TRANS_LINEAR:
	set(v):
		trans_type = v
		queue_redraw()
@export var ease_type: Tween.EaseType = Tween.EASE_IN:
	set(v):
		ease_type = v
		queue_redraw()
@export var bezier: PackedFloat64Array = [0.0, 0.0, 0.0, 0.0]:
	set(v):
		bezier = v
		queue_redraw()
const start: Vector2 = Vector2(0.0, 0.0)
const end: Vector2 = Vector2(1.0, 1.0)
func _draw():
	var graph_rect := Rect2(Vector2(16, 16), size - Vector2(32, 32))
	const samples: int = 64
	draw_line(Vector2(graph_rect.position.x, graph_rect.end.y), Vector2(graph_rect.end.x, graph_rect.end.y), Color.WHITE, 1.0)
	draw_line(Vector2(graph_rect.position.x, graph_rect.position.y), Vector2(graph_rect.position.x, graph_rect.end.y), Color.WHITE, 1.0)
	if trans_type == Tween.TransitionType.TRANS_SPRING:
		var ps := PackedVector2Array()
		var p0 := Vector2(bezier.get(0), bezier.get(1))
		var p1 := Vector2(bezier.get(2), bezier.get(3))
		for i in samples + 1:
			var p := start.bezier_interpolate(p0, p1, end, float(i) / float(samples))
			ps.append(normalize_point(p, graph_rect))
		draw_polyline(ps, Color.CYAN, 4.0, true)
		draw_line(normalize_point(start, graph_rect), normalize_point(p0, graph_rect), Color.DEEP_SKY_BLUE, 2.0)
		draw_line(normalize_point(start, graph_rect), normalize_point(p1, graph_rect), Color.PALE_VIOLET_RED, 2.0)
		draw_circle(normalize_point(p0, graph_rect), 8.0, Color.DEEP_SKY_BLUE)
		draw_circle(normalize_point(p1, graph_rect), 8.0, Color.PALE_VIOLET_RED)
		return
	for i in samples - 1:
		var t0: float = float(i) / (samples - 1)
		var t1: float = float(i + 1) / (samples - 1)
		var y0: float = Tween.interpolate_value(0.0, 1.0, t0, 1.0, trans_type, ease_type)
		var y1: float = Tween.interpolate_value(0.0, 1.0, t1, 1.0, trans_type, ease_type)
		var p0 := Vector2(graph_rect.position.x + t0 * graph_rect.size.x, graph_rect.end.y - y0 * graph_rect.size.y)
		var p1 := Vector2(graph_rect.position.x + t1 * graph_rect.size.x, graph_rect.end.y - y1 * graph_rect.size.y)
		draw_line(p0, p1, Color.CYAN, 4.0)
func normalize_point(p: Vector2, graph_rect: Rect2) -> Vector2:
	p = Vector2(p)
	p.y = 1.0 - p.y
	return graph_rect.position + p * graph_rect.size
func set_trans(v: int) -> void:
	trans_type = v as Tween.TransitionType
	var b := trans_type == Tween.TransitionType.TRANS_SPRING
	$"../EaseLabel".text = tr("bezier") if b else tr("ease")
	$"../Ease".visible = not b
	$"../Bezier".visible = b
func set_ease(v: int) -> void:
	ease_type = v as Tween.EaseType
func set_bezier(text: String) -> void:
	bezier.clear()
	var split := text.split(" ")
	for i in split:
		bezier.append(float(i))
	if bezier.size() > 3:
		queue_redraw()
