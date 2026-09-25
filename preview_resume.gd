extends Panel

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_released():
		$"../../..".visible = false
		$"../../../../Player".start()
