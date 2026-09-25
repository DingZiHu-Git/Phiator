extends PanelContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			$TextureRect.self_modulate = Color.DIM_GRAY
		else:
			$TextureRect.self_modulate = Color.WHITE
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			$TextureRect.self_modulate = Color.DIM_GRAY
		elif event.is_released():
			$TextureRect.self_modulate = Color.WHITE
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				$"../../../../../../..".apply($"../../..")
				Global.make_notification(tr("done"))
