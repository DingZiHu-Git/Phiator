extends PanelContainer

func _ready() -> void:
	pass
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://ok_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://ok_stylebox.tres"))
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://ok_pressed_stylebox.tres"))
		elif event.is_released():
			add_theme_stylebox_override("panel", preload("res://ok_stylebox.tres"))
			if $"../../../../..".visible and Rect2(Vector2.ZERO, size).has_point(event.position):
				$"../../../../..".visible = false
				Global.loaded["line"].remove_at($"../../../../../../PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/Line".value)
				$"../../../../../../Player".reload()
				$"../../../../../..".reload(max(0, $"../../../../../../PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/Line".value - 1))
				Global.make_notification(tr("done"))
