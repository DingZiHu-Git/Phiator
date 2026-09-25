extends PanelContainer

func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	pass
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://ok_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://ok_stylebox.tres"))
	elif event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://ok_pressed_stylebox.tres"))
		elif event.is_released():
			add_theme_stylebox_override("panel", preload("res://ok_stylebox.tres"))
			if $"../../../../..".visible and Rect2(Vector2.ZERO, size).has_point(event.position):
				$"../../../../..".visible = false
				get_tree().change_scene_to_file.call_deferred("res://editor.tscn")
