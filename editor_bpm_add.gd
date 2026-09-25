extends PanelContainer

func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	pass
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
				var bpm = preload("res://bpm.tscn").instantiate()
				$"..".add_child(bpm)
				$"..".move_child(bpm, $"..".get_child_count() - 3)
