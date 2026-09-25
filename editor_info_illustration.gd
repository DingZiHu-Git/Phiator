extends PanelContainer

func _ready() -> void:
	$Label.text = Global.info["illustration"]
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
				DisplayServer.file_dialog_show(tr("select_illustration"), "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["image/*"], func(s: bool, p: PackedStringArray, _i: int):
					if s and p and not p.is_empty():
						DirAccess.remove_absolute(Global.DIR + Global.path + "/" + Global.info["illustration"])
						Global.info.set("illustration", Tools.get_filename(p.get(0)))
						var far := FileAccess.open(p.get(0), FileAccess.READ)
						var faw := FileAccess.open(Global.DIR + Global.path + "/" + Global.info["illustration"], FileAccess.WRITE)
						faw.store_buffer(far.get_buffer(far.get_length()))
						faw.close()
						far.close()
						$Label.text = Global.info["illustration"]
						$"../../../../../../../../../Player".load_info()
						Global.make_notification(tr("done"))
				)
