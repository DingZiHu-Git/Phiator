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
				Global.undo_redo.create_action("modify_event")
				var line: int = $"../../../../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Line".value
				var layer: int = $"../../../../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Event".value
				for i in selected:
					var index: int = i.get_index()
					var t: int = i.type
					var ts: String = i.type_str
					@warning_ignore("incompatible_ternary")
					var new := {"beat":[[int($"../Beat/0".text),int($"../Beat/2".text),int($"../Beat/4".text)],[int($"../Beat2/0".text),int($"../Beat2/2".text),int($"../Beat2/4".text)]],"bezier":(PackedFloat64Array(Array($"../Bezier".text.split(" "))))if($"../Transition".selected==Tween.TransitionType.TRANS_SPRING)else(null),"ease":$"../Ease".selected,"transition":$"../Transition".selected,"value":[float($"../Value".text),float($"../Value2".text)]}
					if $"../../../../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Event".value == 4:
						var ori: Dictionary = Global.loaded["line"].get(line)["extra"][ts].get(index)
						match t:
							0:
								new["value"] = [ $"../Value".text, $"../Value2".text ]
							1:
								new["value"] = [ float($"../Value".text), float($"../Value2".text) ]
							2:
								new["value"] = [ $"../Value".text, $"../Value2".text ]
							3:
								new["value"] = [ float($"../Value".text), float($"../Value2".text) ]
							4:
								new["value"] = [ float($"../Value".text), float($"../Value2".text) ]
						Global.undo_redo.add_do_method(func():
							Global.loaded["line"].get(line)["extra"][ts].set(i.get_index(), new)
						)
						Global.undo_redo.add_undo_method(func():
							Global.loaded["line"].get(line)["extra"][ts].set(i.get_index(), ori)
						)
					else:
						var ori: Dictionary = Global.loaded["line"].get(line)["event"].get(layer)[ts].get(index)
						Global.undo_redo.add_do_method(func():
							Global.loaded["line"].get(line)["event"].get(layer)[ts].set(index, new)
						)
						Global.undo_redo.add_undo_method(func():
							Global.loaded["line"].get(line)["event"].get(layer)[ts].set(index, ori)
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
