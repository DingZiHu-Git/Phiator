extends PanelContainer

var easing: float = 0
var time: float = 0
var index: int = 0
func _ready() -> void:
	pass
func _process(delta: float) -> void:
	if easing <= 0.5:
		move_next()
		easing += delta
	time += delta
	if modulate.a <= 0:
		queue_free()
	elif time >= Global.settings["notificationTime"] - 0.5:
		modulate.a = 1 - (time - Global.settings["notificationTime"] + 0.5) / 0.5
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_released():
		if time < Global.settings["notificationTime"] - 0.5 and Rect2(Vector2.ZERO, size).has_point(event.position):
			time = Global.settings["notificationTime"] - 0.5
func move_next() -> void:
	position.y = Tween.interpolate_value(size.y * (index - 1), size.y, easing, 0.5, Tween.TRANS_CIRC, Tween.EASE_OUT)
