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
				var copy := func():
					var arr: Array[Array] = [["PhiatorClient", "DingZiHu", Global.VER]]
					var temp: Array[Array] = []
					for i in $"../../../../../../Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply".selected:
						temp.append(["e", i.beat.duplicate(), i.easing, i.type_str, i.value, $"../../Event".value < 4])
					for i in $"../../../../../../Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply".selected:
						temp.append(["n", [i.beat, i.endbeat], i.above, i.alpha, i.fake, i.speed, i.type, i.visible_time, i.wide, i.x, i.y])
					if temp.is_empty():
						Global.make_notification(tr("select_item"))
						return [null]
					temp.sort_custom(func(a: Array, b: Array): return Tools.compare_beat(a.get(1).get(0), b.get(1).get(0)) < 0)
					var start: Array = temp.get(0).get(1).get(0)
					for i in temp.size():
						var j: Array = temp.get(i).get(1)
						j.set(0, Tools.beat_subtract(j.get(0), start))
						j.set(1, Tools.beat_subtract(j.get(1), start))
						temp.get(i).set(1, j)
					arr.append_array(temp)
					return arr
				var t := Thread.new()
				t.start(copy)
				DisplayServer.clipboard_set(JSON.stringify(t.wait_to_finish()))
				Global.make_notification(tr("done"))
