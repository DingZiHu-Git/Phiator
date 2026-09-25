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
				var bpm := Array()
				for i in $"..".get_children():
					if i.get_index() < $"..".get_child_count() - 2:
						var beat := i.get_child(1)
						if int(beat.get_child(4).text) == 0:
							Global.make_notification(tr("invalid_value"))
							return
						bpm.append({"beat":[int(beat.get_child(0).text),int(beat.get_child(2).text),int(beat.get_child(4).text)],"bpm":float(i.get_child(3).text)})
				if bpm.size() == 1:
					bpm.get(0).set("beat", [0,0,1])
				Global.loaded.set("bpm", bpm)
				get_tree().root.get_node("Editor/Editor/Player").reload()
				get_tree().root.get_node("Editor/Editor").load_bpm()
				Global.make_notification(tr("done"))
