extends Panel

func _ready() -> void:
	pass
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			self_modulate = Color.DARK_GRAY
		else:
			self_modulate = Color.WHITE
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			self_modulate = Color.DARK_GRAY
		elif event.is_released():
			self_modulate = Color.WHITE
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				$"../../../../Settings".visible = true
