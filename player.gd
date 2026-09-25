extends AspectRatioContainer

var mode: int = 0
var notes: Array = Array()
var note_count: int = 0
var combo: Label = null
var music: AudioStreamPlayer = null
var number: Label = null
var progress: ProgressBar = null
var score: Label = null
var playing: bool = true
func _ready() -> void:
	Log.i("PLAYER: Start loading...")
	_on_resized()
	Global.load_chart()
	music = $Music
	music.stream = Global.stream
	music.volume_linear = Global.settings["music"]
	progress = $MarginContainer/Control/Progress
	load_info()
	combo = $MarginContainer/Control/Combo
	number = $MarginContainer/Control/Number
	score = $MarginContainer/Control/Score/Score
func _process(_delta: float) -> void:
	if music.playing:
		progress.value = music.get_playback_position() - Global.info["offset"] / 1000.0
	var num := int(number.text) > 2
	number.visible = num
	combo.visible = num
	score.text = String.num(Tools.half_up(float(number.text) / float(note_count) * 1000000.0)).split(".").get(0).lpad(7, "0")
func _on_resized() -> void:
	ratio = min(16.0 / 9.0, size.x / size.y)
func set_mode(new_mode: int) -> void:
	mode = new_mode
	if mode > 1:
		playing = false
		if not Global.settings["blur"] and $Illustration.has_node(^"Blur"):
			$Illustration/Blur.queue_free()
	else:
		if mode == 1:
			combo.text = "AUTOPLAY"
		reload()
		start()
func load_info() -> void:
	$Illustration.texture = ImageTexture.create_from_image(Image.load_from_file(Global.DIR + Global.SEPARATOR + Global.path + Global.SEPARATOR + Global.info["illustration"]))
	$Illustration/Black.color.a = Global.settings["black"]
	progress.max_value = music.stream.get_length() - Global.info["offset"] / 1000.0
	$MarginContainer/Control/Chart/Chart.text = Global.info["chart"]
	$MarginContainer/Control/Level/Level.text = Global.info["level"]
func reload(line_id: bool = false) -> void:
	if mode == 2:
		line_id = $"../PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/LineID".button_pressed
	for i in $MarginContainer/Control.get_children():
		if i is TextureRect and i.name != "Pause":
			for j in i.get_children():
				j.queue_free()
			i.queue_free()
	notes.clear()
	number.text = "0"
	note_count = 0
	var rpe: bool = Global.info["format"] == "rpe"
	if Global.sort_chart():
		Global.make_notification(tr("base_event_warn"))
	Global.get_bpm()
	for h in Global.loaded["line"].size():
		var i: Dictionary = Global.loaded["line"].get(h)
		var line = preload("res://line.tscn").instantiate()
		line.get_child(0).text = String.num_uint64(h)
		line.get_child(0).visible = line_id
		line.text = i["texture"]
		if not line.text.is_empty():
			var image := Image.load_from_file(Global.DIR + Global.SEPARATOR + Global.path + Global.SEPARATOR + line.text)
			if image:
				line.texture = ImageTexture.create_from_image(image)
			else:
				Global.make_notification(tr("texture_loaded_failed").format({"texture":line.text}))
		var e: Array[Array]
		var a: Array[Dictionary]
		for j in i["event"]:
			e = []
			a = []
			for k in j["alpha"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0) / (255.0 if rpe else 1.0))
				d.set("delta", k["value"].get(1) / (255.0 if rpe else 1.0) - d["value"])
				a.append(d)
			e.append(a)
			a = []
			for k in j["rotate"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0))
				d.set("delta", k["value"].get(1) - d["value"])
				a.append(d)
			e.append(a)
			a = []
			for k in j["speed"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", 0)
				d.set("transition", 0)
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0) * (120.0 / 900.0 if rpe else 1.0))
				d.set("delta", k["value"].get(1) * (120.0 / 900.0 if rpe else 1.0) - d["value"])
				a.append(d)
			e.append(a)
			a = []
			for k in j["x"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0) / (675.0 if rpe else 1.0))
				d.set("delta", k["value"].get(1) / (675.0 if rpe else 1.0) - d["value"])
				a.append(d)
			e.append(a)
			a = []
			for k in j["y"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0) / (-450.0 if rpe else 1.0))
				d.set("delta", k["value"].get(1) / (-450.0 if rpe else 1.0) - d["value"])
				a.append(d)
			e.append(a)
			line.event.append(e)
		e = []
		a = []
		if i.has("extra"):
			var ex: Dictionary = i["extra"]
			for k in ex["color"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", [k["value"].get(0).substr(0, 2).hex_to_int(), k["value"].get(0).substr(2, 2).hex_to_int(), k["value"].get(0).substr(4, 2).hex_to_int()])
				d.set("delta", [k["value"].get(1).substr(0, 2).hex_to_int() - d["value"].get(0), k["value"].get(1).substr(2, 2).hex_to_int() - d["value"].get(1), k["value"].get(1).substr(4, 2).hex_to_int() - d["value"].get(2)])
				a.append(d)
			e.append(a)
			a = []
			for k in ex["incline"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0))
				d.set("delta", k["value"].get(1) - d["value"])
				a.append(d)
			e.append(a)
			a = []
			for k in ex["text"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0))
				a.append(d)
			e.append(a)
			a = []
			for k in ex["x"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0))
				d.set("delta", k["value"].get(1) - d["value"])
				a.append(d)
			e.append(a)
			a = []
			for k in ex["y"]:
				var d: Dictionary = Dictionary()
				d.set("bezier", k["bezier"]if(k.has("bezier"))else(null))
				d.set("ease", k["ease"])
				d.set("transition", k["transition"])
				d.set("time", [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ])
				d.set("value", k["value"].get(0))
				d.set("delta", k["value"].get(1) - d["value"])
				a.append(d)
			e.append(a)
			line.extra = e
		line.father = i["father"]
		for k in i["note"].size():
			var n: Dictionary = i["note"].get(k).duplicate()
			n["line"] = h
			notes.append(n)
		if i.has("z"):
			line.z_index = i["z"]
		$MarginContainer/Control.add_child(line)
		$MarginContainer/Control.move_child(line, h)
	notes.sort_custom(func(b1: Dictionary, b2: Dictionary): return Tools.compare_beat(b1["beat"].get(0) if b1["beat"].size() == 2 else b1["beat"], b2["beat"].get(0) if b2["beat"].size() == 2 else b2["beat"]) < 0)
	for k in notes.size():
		var last: Dictionary
		if k > 0:
			last = notes.get(k - 1)
		var j: Dictionary = notes.get(k)
		var next: Dictionary
		if k < notes.size() - 1:
			next = notes.get(k + 1)
		var note: TextureRect
		var beat: Array = j["beat"]
		var t: int = j["type"]
		match t:
			1:
				note = (preload("res://hold.tscn") if beat.size() == 2 else preload("res://tap.tscn")).instantiate()
				note.multiple = (last and Tools.compare_beat(last["beat"] if last["beat"].size() == 3 else last["beat"].get(0), beat if beat.size() == 3 else beat.get(0)) == 0) or (next and Tools.compare_beat(next["beat"] if next["beat"].size() == 3 else next["beat"].get(0), beat if beat.size() == 3 else beat.get(0)) == 0)
			2:
				note = preload("res://flick.tscn").instantiate()
				note.multiple = (last and Tools.compare_beat(last["beat"] if last["beat"].size() == 3 else last["beat"].get(0), beat) == 0) or (next and Tools.compare_beat(next["beat"] if next["beat"].size() == 3 else next["beat"].get(0), beat) == 0)
			3:
				note = preload("res://drag.tscn").instantiate()
				note.multiple = (last and Tools.compare_beat(last["beat"] if last["beat"].size() == 3 else last["beat"].get(0), beat) == 0) or (next and Tools.compare_beat(next["beat"] if next["beat"].size() == 3 else next["beat"].get(0), beat) == 0)
		note.alpha = j["alpha"] / (255.0 if rpe else 1.0)
		note.above = j["above"]
		note.fake = j["fake"]
		note.time = Tools.beat_to_time(beat.get(0) if beat.size() == 2 else beat)
		note.hold = (Tools.beat_to_time(beat.get(1)) - note.time) if beat.size() == 2 else 0.0
		note.type = t
		note.visible_time = j["visible"] if j.has("visible") else 9999999.0
		note.wide = j["wide"]
		note.x = j["x"] / (675.0 if rpe else 1.0)
		note.y = j["y"] / (450.0 if rpe else 1.0)
		note.speed = j["speed"]
		note.z_as_relative = false
		$MarginContainer/Control.get_child(j["line"]).add_child(note)
		if not j["fake"]:
			note_count += 1
func start(p: float = progress.value) -> void:
	progress.value = p
	var offset: float = Global.info["offset"] / 1000.0
	if offset < 0 and p < -offset:
		var interval: float = get_physics_process_delta_time()
		get_tree().create_timer(interval, true, false, true).timeout.connect(func():
			if playing:
				progress.value += interval
				start(progress.value)
		)
	else:
		$Music.play(p + offset)
	playing = true
func stop() -> void:
	playing = false
	$Music.stop()
