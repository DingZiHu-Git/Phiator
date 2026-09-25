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
				DisplayServer.file_dialog_show(tr("import_skin"), "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILES, ["*.zip;Skin file;application/zip"], func(s: bool, p: PackedStringArray, _i: int):
					if s and p and not p.is_empty():
						for i in p:
							var zr := ZIPReader.new()
							zr.open(i)
							if not zr.file_exists("info.json"):
								zr.close()
								Global.make_notification(tr("unsupported_format"))
								return
							zr.close()
							Tools.copy_file(i, Global.DIR + "skins/" + Tools.get_filename(i))
						$"../..".refresh()
						Global.make_notification(tr("done"))
				)
