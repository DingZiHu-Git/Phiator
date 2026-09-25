extends MenuButton

func _ready() -> void:
	var popup: PopupMenu = get_popup()
	popup.index_pressed.connect(func(index: int):
		match popup.get_item_text(index):
			"copy_chart":
				Global.info = $"../..".info
				Global.export_chart("phiator", Global.DIR + "cache/temp.zip", String.num_uint64(RandomNumberGenerator.new().randi()), false)
				Global.import_chart(Global.DIR + "cache/temp.zip")
				Tools.clear_folder(Global.DIR + "cache")
				$"../../..".refresh()
			"preview_chart":
				Global.info = $"../..".info
				if Global.VER < $"../..".info["lastEdit"]:
					$"../../../../../../../Warning".visible = true
				else:
					get_tree().change_scene_to_file.call_deferred("res://preview.tscn")
	)
