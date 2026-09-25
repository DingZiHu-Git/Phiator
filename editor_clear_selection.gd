extends PanelContainer

func _ready() -> void:
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
				for i in $"../../../../../Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply".selected:
					i.self_modulate = Color.WHITE
				$"../../../../../Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply".selected.clear()
				for i in $"../../../../../Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply".selected:
					i.self_modulate = Color.WHITE
				$"../../../../../Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply".selected.clear()
				Global.make_notification(tr("done"))
