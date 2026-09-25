extends PanelContainer

func _ready() -> void:
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
				DisplayServer.file_dialog_show(tr("import"), "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.gif,*.jpeg,*.jpg,*.png,*.webp;Image file;image/*"], func(_s: bool, p: PackedStringArray, _i: int):
					DirAccess.remove_absolute(Global.DIR + Global.path + "/" + $Label.text)
					$Label.text = tr("default")
					if not p or p.is_empty():
						return
					var fn := Tools.get_filename(p.get(0))
					var fa := FileAccess.open(p.get(0), FileAccess.READ)
					var b := fa.get_buffer(fa.get_length())
					fa.close()
					fa = FileAccess.open(Global.DIR + Global.path + "/" + fn, FileAccess.WRITE)
					fa.store_buffer(b)
					fa.close()
					$Label.text = fn
				)
