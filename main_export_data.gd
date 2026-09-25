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
				DisplayServer.file_dialog_show(tr("export_data"), "", "PhiatorData.dat", true, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, ["application/octet-stream"], func(s: bool, p: PackedStringArray, _i: int):
					if s and p and not p.is_empty():
						var zp := ZIPPacker.new()
						zp.open(p.get(0))
						var da := DirAccess.open(Global.DIR)
						da.list_dir_begin()
						var fn := da.get_next()
						while fn != "":
							if da.current_is_dir():
								var d := DirAccess.open(Global.DIR + fn)
								d.list_dir_begin()
								var f := d.get_next()
								while f != "":
									zp.start_file(fn + "/" + f)
									var fa := FileAccess.open(d.get_current_dir() + "/" + f, FileAccess.READ)
									zp.write_file(fa.get_buffer(fa.get_length()))
									zp.close_file()
									fa.close()
									f = d.get_next()
							else:
								zp.start_file(fn)
								var fa := FileAccess.open(Global.DIR + fn, FileAccess.READ)
								zp.write_file(fa.get_buffer(fa.get_length()))
								zp.close_file()
								fa.close()
							fn = da.get_next()
						zp.close()
						Global.make_notification(tr("done"))
				)
