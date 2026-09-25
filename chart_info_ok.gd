extends PanelContainer

var illustration: String = "res://icon_trans.png"
var music: String
var format: String = ""
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://ok_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://ok_stylebox.tres"))
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://ok_pressed_stylebox.tres"))
		elif event.is_released():
			add_theme_stylebox_override("panel", preload("res://ok_stylebox.tres"))
			if $"../../../../..".visible and Rect2(Vector2.ZERO, size).has_point(event.position):
				var path: String = $"../../HBoxContainer/LineEdits/Path".text
				$"../../../../..".visible = false
				Log.i("Creating chart...")
				var r = FileAccess.open(music, FileAccess.READ)
				if not r:
					Log.e("Error when loading the audio: " + str(FileAccess.get_open_error()))
				var fn: String = Tools.parse_music(music, format)
				var fa = FileAccess.open(Global.DIR + path + "/" + fn, FileAccess.WRITE)
				if not fa:
					Log.e("Error when copying the audio: " + str(FileAccess.get_open_error()))
				fa.store_buffer(r.get_buffer(r.get_length()))
				fa.close()
				r.close()
				r = FileAccess.open(illustration, FileAccess.READ)
				fa = FileAccess.open(Global.DIR + path + "/" + Tools.get_filename(illustration), FileAccess.WRITE)
				fa.store_buffer(r.get_buffer(r.get_length()))
				fa.close()
				r.close()
				fa = FileAccess.open(Global.DIR + path + "/" + "info.json", FileAccess.WRITE)
				fa.store_string(JSON.stringify({"artist":$"../../HBoxContainer/LineEdits/Artist".text,"author":$"../../HBoxContainer/LineEdits/Author".text,"chart":$"../../HBoxContainer/LineEdits/Chart".text,"illustration":Tools.get_filename(illustration),"illustrator":$"../../HBoxContainer/LineEdits/Illustrator".text,"lastEdit":Global.VER,"level":$"../../HBoxContainer/LineEdits/Level".text,"music":fn,"offset":0,"path":path}))
				fa.close()
				fa = FileAccess.open(Global.DIR + path + "/" + path + ".json", FileAccess.WRITE)
				fa.store_string(JSON.stringify({"bpm":[{"beat":[0,0,1],"bpm":120.0}],"line":[{"bpmFactor":1.0,"cover":true,"event":[{"alpha":[{"beat":[[0,0,1],[1,0,1]],"bezier":null,"ease":0,"transition":0,"value":[0.0,0.0]}],"rotate":[{"beat":[[0,0,1],[1,0,1]],"bezier":null,"ease":0,"transition":0,"value":[0.0,0.0]}],"speed":[{"beat":[[0,0,1],[1,0,1]],"bezier":null,"ease":0,"transition":0,"value":[1.0,1.0]}],"x":[{"beat":[[0,0,1],[1,0,1]],"bezier":null,"ease":0,"transition":0,"value":[0.0,0.0]}],"y":[{"beat":[[0,0,1],[1,0,1]],"bezier":null,"ease":0,"transition":0,"value":[0.0,0.0]}]}],"father":-1,"note":[],"texture":"","ui":0,"z":0}]}))
				fa.close()
				$"../../../../../../HBoxContainer/ScrollContainer/MarginContainer/ChartList".refresh()
func select_files() -> void:
	DisplayServer.file_dialog_show(tr("create_chart") + " - " + tr("select_music"), "", "", true, DisplayServer.FILE_DIALOG_MODE_OPEN_FILE, ["audio/*"], func(_s: bool, p: PackedStringArray, _i: int):
		if p == null or p.is_empty():
			return
		if AudioStreamMP3.load_from_file(p.get(0)):
			format = "mp3"
		elif AudioStreamOggVorbis.load_from_file(p.get(0)):
			format = "ogg"
		elif AudioStreamWAV.load_from_file(p.get(0)):
			format = "wav"
		else:
			Global.make_notification(tr("unsupported_format"))
			return
		music = p.get(0)
		var temp := Tools.get_filename(music)
		$"../../HBoxContainer/LineEdits/Chart".text = temp.substr(0, temp.rfind("."))
		$"../../HBoxContainer/LineEdits/Artist".text = ""
		$"../../HBoxContainer/LineEdits/Illustrator".text = ""
		$"../../HBoxContainer/LineEdits/Level".text = "SP Lv.?"
		$"../../HBoxContainer/LineEdits/Author".text = Global.user
		$"../../HBoxContainer/LineEdits/Path".text = String.num_int64(RandomNumberGenerator.new().randi())
		$"../../../../..".visible = true
	)
