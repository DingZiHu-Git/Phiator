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
				DisplayServer.file_dialog_show(tr("import_chart"), "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["*.pez,*.zip;Chart files"], func(_s: bool, p: PackedStringArray, _i: int):
					if p == null or p.is_empty():
						return
					Global.import_chart(p.get(0))
					$"../../../ScrollContainer/MarginContainer/ChartList".refresh()
				)
