extends VBoxContainer

func _ready() -> void:
	$"../..".get_v_scroll_bar().custom_minimum_size.x = 28
func refresh() -> void:
	for i in get_children():
		i.queue_free()
	var dir: DirAccess = DirAccess.open(Global.DIR)
	dir.list_dir_begin()
	var d: String = dir.get_next()
	while d != "":
		if dir.current_is_dir():
			var di: DirAccess = DirAccess.open(Global.DIR + Global.SEPARATOR + d)
			di.list_dir_begin()
			var f: String = di.get_next()
			while f != "":
				if f.to_lower() == "info.json":
					var chart = preload("res://chart.tscn").instantiate()
					var fa = FileAccess.open(di.get_current_dir() + Global.SEPARATOR + f, FileAccess.READ)
					var info = JSON.parse_string(fa.get_as_text())
					fa.close()
					info.set("lastEdit", int(info["lastEdit"]))
					info.set("offset", int(info["offset"]))
					chart.init(info)
					add_child(chart)
					break
				f = di.get_next()
			di.list_dir_end()
		d = dir.get_next()
	dir.list_dir_end()
	var ill: TextureRect = $"../../../../Illustration"
	match int(Global.settings["background"]):
		0:
			ill.texture = null
		1:
			ill.texture = preload("res://icon.png")
		2:
			if get_child_count() > 0:
				ill.texture = get_child(randi_range(0, get_child_count() - 1)).get_node("Illustration").texture
			else:
				ill.texture = preload("res://icon.png")
