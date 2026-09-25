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
				var line = Global.loaded["line"].get($"../../../../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Line".value)
				line.set("bpmFactor", float($"../BPMFactor".text))
				line.set("cover", $"../Cover".button_pressed)
				line.set("father", $"../Father".value)
				line.set("texture", "" if $"../Texture/Label".text == tr("default") else $"../Texture/Label".text)
				line.set("ui", $"../UI".selected)
				line.set("z", $"../Z".value)
				$"../../../../../../../../../Player".reload()
				$"../../../../../../../../..".reload(max(0, $"../../../../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Line".value - 1))
				Global.make_notification(tr("done"))
