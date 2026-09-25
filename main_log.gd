extends Panel

func _ready() -> void:
	pass
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			self_modulate = Color.DARK_GRAY
		else:
			self_modulate = Color.WHITE
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			self_modulate = Color.DARK_GRAY
		elif event.is_released():
			self_modulate = Color.WHITE
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				var latest: String = Log.get_latest_log()
				if latest == "":
					Global.make_notification(tr("no_latest_log"))
					return
				DisplayServer.file_dialog_show(tr("export_log"), "", latest, true, DisplayServer.FILE_DIALOG_MODE_SAVE_FILE, ["*.log;Log file;application/octet-stream"], func(_s: bool, p: PackedStringArray, _i: int):
					if not p or p.is_empty():
						return
					var r: FileAccess = FileAccess.open(Log._lp + latest, FileAccess.READ)
					var fa: FileAccess = FileAccess.open(p.get(0), FileAccess.WRITE)
					fa.store_buffer(r.get_buffer(r.get_length()))
					fa.close()
					r.close()
					Global.make_notification(tr("done"))
				)
