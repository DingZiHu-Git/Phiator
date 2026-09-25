extends ColorRect

var v: Vector2
var a: Vector2
var m: float
var t: float
var p: TextureRect
func _ready() -> void:
	v = Vector2(RandomNumberGenerator.new().randf_range(-16, 16), RandomNumberGenerator.new().randf_range(-16, 16))
	m = v.x * v.y
	a = v / RandomNumberGenerator.new().randi_range(16, 64)
	p = get_parent()
func _process(delta: float) -> void:
	t += delta
	if t < 1 / p.fps:
		return
	position += v
	t = 0
	v -= a
	self_modulate.a = min(1 - float(p.index) / p.frames.size(), v.x * v.y / m)
	if self_modulate.a < 6e-3:
		queue_free()
