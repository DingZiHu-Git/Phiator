extends PanelContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://cancel_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://cancel_stylebox.tres"))
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://cancel_pressed_stylebox.tres"))
		elif event.is_released():
			add_theme_stylebox_override("panel", preload("res://cancel_stylebox.tres"))
			if $"../../../../..".visible and Rect2(Vector2.ZERO, size).has_point(event.position):
				$"../../../../..".visible = false
