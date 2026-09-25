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
				Global.info.set("chart", $"../Chart".text)
				Global.info.set("artist", $"../Artist".text)
				Global.info.set("illustrator", $"../Illustrator".text)
				Global.info.set("level", $"../Level".text)
				Global.info.set("author", $"../Author".text)
				Global.info.set("offset", int(Tools.half_up(float($"../Offset".text))))
				$"../../../../../../../../../Player".load_info()
				$"../../../../../../../PanelContainer/Operations/Progress".max_value = Global.stream.get_length() - Global.info["offset"] / 1000.0
				Global.make_notification(tr("done"))
