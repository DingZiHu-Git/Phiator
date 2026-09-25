extends PanelContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		elif event.is_released():
			add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				get_tree().root.get_node("Editor/Editor/Help").visible = true
