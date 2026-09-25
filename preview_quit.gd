extends Panel

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_released():
		get_tree().change_scene_to_file("res://main.tscn")
