extends TextureRect

const fps: float = 60
var timer: Timer = Timer.new()
var frames: Array = []
var index: int = 0
func _ready() -> void:
	frames = Global.skin["hx"]
	timer.wait_time = 1.0 / fps
	timer.ignore_time_scale = true
	timer.timeout.connect(func():
		index += 1
		if index == frames.size():
			queue_free()
		else:
			texture = frames.get(index)
	)
	timer.autostart = true
	add_child(timer)
	if Global.skin["p"]:
		for i in 4:
			var p := preload("res://particle.tscn").instantiate()
			p.position.x = size.x / 2
			p.position.y = size.y / 2
			p.size = size / 12
			p.color = self_modulate
			add_child(p)
