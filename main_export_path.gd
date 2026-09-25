extends PanelContainer

var path: String = ""
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
				DisplayServer.file_dialog_show(tr("select"), "", Global.info["path"] + ".zip", true, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, ["*.zip;Chart files;application/zip"], func(s: bool, p: PackedStringArray, _i: int):
					if s and p and not p.is_empty():
						path = p.get(0)
						$Label.text = Tools.get_filename(path)
				)
