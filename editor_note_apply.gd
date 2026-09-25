extends PanelContainer

var selected: Array[TextureRect] = []
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
				if selected.is_empty():
					Global.make_notification(tr("select_item"))
					return
				if int($"../Beat/4".text) == 0 or int($"../Beat2/4".text) == 0:
					Global.make_notification(tr("invalid_value"))
					return
				Global.undo_redo.create_action("modify_note")
				for i in selected:
					var index: int = i.get_index()
					var line: int = $"../../../../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Line".value
					var t: int = i.type
					var ori: Dictionary = Global.loaded["line"].get(line)["note"].get(index)
					var new := {"above":$"../Above".button_pressed,"alpha":float($"../Alpha".text),"beat":[int($"../Beat/0".text),int($"../Beat/2".text),int($"../Beat/4".text)]if(i.hold==0.0)else([[int($"../Beat/0".text),int($"../Beat/2".text),int($"../Beat/4".text)],[int($"../Beat2/0".text),int($"../Beat2/2".text),int($"../Beat2/4".text)]]),"fake":$"../Fake".button_pressed,"visible":float($"../Visible".text),"wide":float($"../Wide".text),"speed":float($"../Speed".text),"type":t,"x":float($"../X".text),"y":float($"../Y".text)}
					Global.undo_redo.add_do_method(func():
						Global.loaded["line"].get(line)["note"].set(index, new)
					)
					Global.undo_redo.add_undo_method(func():
						Global.loaded["line"].get(line)["note"].set(index, ori)
					)
				Global.undo_redo.add_do_method(func():
					get_tree().root.get_node("Editor/Editor/Player").reload()
					get_tree().root.get_node("Editor/Editor").reload()
				)
				Global.undo_redo.add_undo_method(func():
					get_tree().root.get_node("Editor/Editor/Player").reload()
					get_tree().root.get_node("Editor/Editor").reload()
				)
				Global.undo_redo.commit_action()
				Global.make_notification(tr("done"))
