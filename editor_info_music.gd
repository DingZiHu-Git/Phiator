extends PanelContainer

func _ready() -> void:
	$Label.text = Global.info["music"]
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
				DisplayServer.file_dialog_show(tr("select_music"), "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["audio/*"], func(s: bool, p: PackedStringArray, _i: int):
					if s and p and not p.is_empty():
						DirAccess.remove_absolute(Global.DIR + Global.path + "/" + Global.info["music"])
						Global.info.set("music", Tools.parse_music(p.get(0)))
						var far := FileAccess.open(p.get(0), FileAccess.READ)
						var faw := FileAccess.open(Global.DIR + Global.path + "/" + Global.info["music"], FileAccess.WRITE)
						faw.store_buffer(far.get_buffer(far.get_length()))
						faw.close()
						far.close()
						$Label.text = Global.info["music"]
						Global.load_music()
						$"../../../../../../../PanelContainer/Operations/Progress".max_value = Global.stream.get_length() - Global.info["offset"] / 1000.0
						$"../../../../../../../../../Player".load_info()
						Global.make_notification(tr("done"))
				)
