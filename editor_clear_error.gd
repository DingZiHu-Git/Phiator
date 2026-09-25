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
				var e: int = 0
				var n: int = 0
				for i in Global.loaded["line"]:
					for j in i["event"]:
						for k in j["alpha"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["alpha"].erase(k)
								e += 1
						for k in j["rotate"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["rotate"].erase(k)
								e += 1
						for k in j["speed"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["speed"].erase(k)
								e += 1
						for k in j["x"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["x"].erase(k)
								e += 1
						for k in j["y"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["y"].erase(k)
								e += 1
					if i.has("extra"):
						var j: Dictionary = i["extra"]
						for k in j["color"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["color"].erase(k)
								e += 1
						for k in j["incline"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["incline"].erase(k)
								e += 1
						for k in j["text"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["text"].erase(k)
								e += 1
						for k in j["x"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["x"].erase(k)
								e += 1
						for k in j["y"]:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								j["y"].erase(k)
								e += 1
					for k in i["note"]:
						if k["beat"].size() == 2:
							if k["beat"].get(0).get(2) == 0 or k["beat"].get(1).get(2) == 0 or Tools.compare_beat(k["beat"].get(0), k["beat"].get(1)) >= 0:
								i["note"].erase(k)
								n += 1
						else:
							if k["beat"].get(2) == 0:
								i["note"].erase(k)
								n += 1
						if abs(k["x"]) > (675.0 if Global.settings["data"] == "rpe" else 1.0):
							i["note"].erase(k)
							n += 1
				$"../../../../../../../../Player".reload()
				$"../../../../../../../..".reload()
				Global.make_notification(tr("clear_error_msg").format({"note":n,"event":e}))
