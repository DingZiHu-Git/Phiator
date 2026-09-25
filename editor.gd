extends AspectRatioContainer

@onready var progress: HSlider = $PanelContainer/VBoxContainer/PanelContainer/Operations/Progress
@onready var h_lines_scroll: ScrollContainer = $PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/HLines
@onready var scroll: ScrollContainer = $PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/ScrollContainer
@onready var note: Control = scroll.get_child(0).get_child(0)
@onready var event: Control = scroll.get_child(0).get_child(1)
@onready var beats: ScrollContainer = $PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/Beats
@onready var interval: HSlider = $PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/Interval
@onready var h_lines: SpinBox = $PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/HLines
@onready var h_lines_scroll_bar: VScrollBar = h_lines_scroll.get_v_scroll_bar()
@onready var v_lines: SpinBox = $PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/VLines
@onready var line: SpinBox = $PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/Line
@onready var line_id: CheckButton = $PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/LineID
@onready var event_layer: HSlider = $PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/Event
@onready var note_apply: PanelContainer = $PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply
@onready var event_apply: PanelContainer = $PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply
var holding: TextureRect = null
var eventing: TextureRect = null
var last_interval: float = 0.5
var dragged: bool = false
var touched: bool = false
var changed: bool = false
var player: AspectRatioContainer = null
var player_progress: ProgressBar = null
func _ready() -> void:
	Log.i("EDITOR: Start loading...")
	load_safe_zone(Global.settings["safeZone"])
	$PanelContainer/VBoxContainer/Control/Operations/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 24
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 24
	Global.info.set("lastEdit", Global.VER)
	Global.info.set("format", Global.settings["data"])
	player = $Player
	player.set_mode(2)
	player.reload()
	player_progress = $Player/MarginContainer/Control/Progress
	progress.max_value = player_progress.max_value
	Global.get_properties()
	line_id.button_pressed = Global.properties["lineID"]
	h_lines.value = Global.properties["hLines"]
	v_lines.value = Global.properties["vLines"]
	interval.value = Global.properties["interval"]
	$PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/Lines/Note.refresh.call_deferred(v_lines.value)
	refresh_h_lines.call_deferred()
	load_bpm.call_deferred()
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Info/Chart.text = Global.info["chart"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Info/Artist.text = Global.info["artist"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Info/Illustrator.text = Global.info["illustrator"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Info/Level.text = Global.info["level"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Info/Author.text = Global.info["author"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Info/Offset.text = String.num_int64(Global.info["offset"])
	Global.fps = $Info/FPS
	Global.notifications = $Notifications/Control
	Global.undo_redo = UndoRedo.new()
	Global.undo_redo.max_steps = Global.settings["history"]
	_on_line_id_toggled(line_id.button_pressed)
	$PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/SpeedLabel.text = tr("music_speed") + ": 1.0"
	$PanelContainer/VBoxContainer/PanelContainer/Operations/Select.set_item_icon(1, Global.skin["t"]["t"])
	$PanelContainer/VBoxContainer/PanelContainer/Operations/Select.set_item_icon(2, Global.skin["t"]["h"])
	$PanelContainer/VBoxContainer/PanelContainer/Operations/Select.set_item_icon(3, Global.skin["t"]["f"])
	$PanelContainer/VBoxContainer/PanelContainer/Operations/Select.set_item_icon(4, Global.skin["t"]["d"])
	if $Timer.is_stopped():
		Global.make_notification(tr("auto_save_disabled"))
func _process(_delta: float) -> void:
	if player.playing:
		progress.value = player_progress.value
	_on_progress_value_changed(progress.value)
func _on_resized() -> void:
	ratio = size.x / size.y
func load_safe_zone(safe_zone: float):
	var ps: Vector2 = $"..".size
	$"..".add_theme_constant_override(&"margin_bottom", (ps.y - ps.y * safe_zone) / 2)
	$"..".add_theme_constant_override(&"margin_left", (ps.x - ps.x * safe_zone) / 2)
	$"..".add_theme_constant_override(&"margin_right", (ps.x - ps.x * safe_zone) / 2)
	$"..".add_theme_constant_override(&"margin_top", (ps.y - ps.y * safe_zone) / 2)
func load_bpm() -> void:
	var sy: float = $"..".size.y * Global.settings["safeZone"]
	for i in Global.bpm.size():
		note.custom_minimum_size.y += (((Global.stream.get_length() + 91) if i == Global.bpm.size() - 1 else Global.bpm.get(i + 1)["time"]) - Global.bpm.get(i)["time"]) * Global.bpm.get(i)["bpm"] / 60 * sy * interval.value
	event.custom_minimum_size.y = note.custom_minimum_size.y
	$PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/Beats/VBoxContainer/Beats.custom_minimum_size.y = note.custom_minimum_size.y
	var i: int = 0
	var y: float = note.custom_minimum_size.y
	while y > 0:
		var beat := Label.new()
		beat.offset_transform_enabled = true
		beat.offset_transform_position_ratio = Vector2(-1, -1)
		beat.offset_transform_visual_only = false
		beat.text = String.num_uint64(i)
		beat.add_theme_font_size_override("font_size", 24)
		beat.position.y = y
		$PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/Beats/VBoxContainer/Beats.add_child(beat)
		i += 1
		y -= size.y * interval.value
	for j in $PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/BPM.get_children():
		if j is VBoxContainer:
			j.queue_free()
	for j in Global.loaded["bpm"]:
		var bpm = preload("res://bpm.tscn").instantiate()
		var beat = bpm.get_child(1)
		beat.get_child(0).text = String.num_uint64(j["beat"].get(0))
		beat.get_child(2).text = String.num_uint64(j["beat"].get(1))
		beat.get_child(4).text = String.num_uint64(j["beat"].get(2))
		bpm.get_child(3).text = String.num(j["bpm"])
		$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/BPM.add_child(bpm)
		$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/BPM.move_child(bpm, -3)
	reload_deferred()
func refresh_h_lines(_p = 0) -> void:
	var _note = h_lines_scroll.get_child(0).get_child(0)
	var _event = h_lines_scroll.get_child(0).get_child(1)
	for i in _note.get_children():
		i.queue_free()
	for i in _event.get_children():
		i.queue_free()
	var i: float = 0
	while i < size.y + interval.value * size.y * 2:
		i += interval.value * size.y
	_note.custom_minimum_size.y = i
	_event.custom_minimum_size.y = i
	while i > 0:
		for k in h_lines.value:
			var color := ColorRect.new()
			color.offset_transform_enabled = true
			color.offset_transform_position_ratio.y = -0.5
			color.offset_transform_visual_only = false
			color.size.y = 2
			color.anchor_right = 1
			color.position.y = i - k * interval.value * size.y / h_lines.value
			color.color = Color.RED if k == 0 else Color.GREEN
			_note.add_child(color)
			color = ColorRect.new()
			color.offset_transform_enabled = true
			color.offset_transform_position_ratio.y = -0.5
			color.offset_transform_visual_only = false
			color.size.y = 2
			color.anchor_right = 1
			color.position.y = i - k * interval.value * size.y / h_lines.value
			color.color = Color.RED if k == 0 else Color.GREEN
			_event.add_child(color)
		i -= interval.value * size.y
func refresh(value: float) -> void:
	var delta = value / last_interval
	for i in scroll.get_child(0).get_child_count():
		for j in scroll.get_child(0).get_child(i).get_children():
			if i == 1:
				for k in j.get_children():
					k.position.y *= delta
					k.size.y *= delta
			else:
				j.position.y *= delta
				if j.hold != 0:
					j.size.y *= delta
		scroll.get_child(0).get_child(i).custom_minimum_size.y *= delta
	for i in $PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/Beats/VBoxContainer/Beats.get_children():
		i.position.y *= delta
	$PanelContainer/VBoxContainer/Control/PanelContainer/AspectRatioContainer/Beats/VBoxContainer/Beats.custom_minimum_size.y *= delta
	last_interval = value
func reload_deferred() -> void:
	await get_tree().process_frame
	reload.call_deferred()
func reload(_value: float = 0) -> void:
	note_apply.selected.clear()
	event_apply.selected.clear()
	line.max_value = Global.loaded["line"].size() - 1
	var l: Dictionary = Global.loaded["line"].get(line.value)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Line/Father.max_value = Global.loaded["line"].size() - 1
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Line/BPMFactor.text = String.num(l["bpmFactor"])
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Line/Cover.button_pressed = l["cover"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Line/Father.value = l["father"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Line/Texture/Label.text = tr("default") if l["texture"].is_empty() else l["texture"]
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Line/UI.selected = l["ui"]
	for i in note.get_children():
		i.queue_free()
	for i in event.get_children():
		for j in i.get_children():
			j.queue_free()
	var rpe: bool = Global.info["format"] == "rpe"
	var last_beat: Array = [-1, 0, 1]
	var last_x: float = 0.0
	var last_rotation: float = 0.0
	for k in l["note"]:
		var n: TextureRect
		var b: Array = k["beat"]
		var t := int(k["type"])
		match t:
			1:
				n = (preload("res://hold.tscn") if b.size() == 2 else preload("res://tap.tscn")).instantiate()
			2:
				n = preload("res://flick.tscn").instantiate()
			3:
				n = preload("res://drag.tscn").instantiate()
		n.editor = true
		n.above = k["above"]
		n.alpha = k["alpha"]
		n.fake = k["fake"]
		n.speed = k["speed"]
		n.type = t
		n.visible_time = k["visible"]
		n.wide = k["wide"]
		n.x = k["x"]
		n.y = k["y"]
		n.position.x = (k["x"] + (675.0 if rpe else 1.0)) / (1350.0 if rpe else 2.0) * note.size.x
		var obj: Dictionary = k.duplicate()
		obj["line"] = int(line.value)
		obj["ori"] = k
		n.obj = obj
		if b.size() == 2:
			n.beat = b.get(0)
			n.endbeat = b.get(1)
			n.hold = 1.0
			n.size.y = (Tools.beat_to_float(n.endbeat) - Tools.beat_to_float(n.beat)) * interval.value * size.y
			n.position.y = note.size.y - Tools.beat_to_float(n.beat) * interval.value * size.y
			n.z_index = 0
		else:
			last_rotation = last_rotation + 30.0 if Tools.compare_beat(last_beat, b) == 0 and last_x == k["x"] else 0.0
			n.rotation_degrees = last_rotation
			last_beat = b
			last_x = k["x"]
			n.beat = last_beat
			n.endbeat = n.beat
			n.position.y = note.size.y - Tools.beat_to_float(b) * interval.value * size.y
			n.z_index = 1
		note.add_child(n)
	if event_layer.value == 4:
		if not l.has("extra"):
			var new: Dictionary = Dictionary()
			new.set("color", Array())
			new.set("incline", Array())
			new.set("text", Array())
			new.set("x", Array())
			new.set("y", Array())
			l.set("extra", new)
		var ex: Dictionary = l["extra"]
		for k in ex["color"]:
			var hold := preload("res://event.tscn").instantiate()
			hold.beat = k["beat"]
			hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
			hold.easing = [ k["transition"], k["ease"] ]
			hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
			hold.type = 0
			hold.type_str = "color"
			hold.value = k["value"]
			hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
			hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
			var obj: Dictionary = k.duplicate()
			obj["line"] = int(line.value)
			obj["layer"] = 4
			obj["ori"] = k
			hold.obj = obj
			event.get_child(0).add_child(hold)
		for k in ex["incline"]:
			var hold := preload("res://event.tscn").instantiate()
			hold.beat = k["beat"]
			hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
			hold.easing = [ k["transition"], k["ease"] ]
			hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
			hold.type = 1
			hold.type_str = "incline"
			hold.value = k["value"]
			hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
			hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
			var obj: Dictionary = k.duplicate()
			obj["line"] = int(line.value)
			obj["layer"] = 4
			obj["ori"] = k
			hold.obj = obj
			event.get_child(1).add_child(hold)
		for k in ex["text"]:
			var hold := preload("res://event.tscn").instantiate()
			hold.beat = k["beat"]
			hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
			hold.easing = [ k["transition"], k["ease"] ]
			hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
			hold.type = 2
			hold.type_str = "text"
			hold.value = k["value"]
			hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
			hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
			var obj: Dictionary = k.duplicate()
			obj["line"] = int(line.value)
			obj["layer"] = 4
			obj["ori"] = k
			hold.obj = obj
			event.get_child(2).add_child(hold)
		for k in ex["x"]:
			var hold := preload("res://event.tscn").instantiate()
			hold.beat = k["beat"]
			hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
			hold.easing = [ k["transition"], k["ease"] ]
			hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
			hold.type = 3
			hold.type_str = "x"
			hold.value = k["value"]
			hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
			hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
			var obj: Dictionary = k.duplicate()
			obj["line"] = int(line.value)
			obj["layer"] = 4
			obj["ori"] = k
			hold.obj = obj
			event.get_child(3).add_child(hold)
		for k in ex["y"]:
			var hold := preload("res://event.tscn").instantiate()
			hold.beat = k["beat"]
			hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
			hold.easing = [ k["transition"], k["ease"] ]
			hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
			hold.type = 4
			hold.type_str = "y"
			hold.value = k["value"]
			hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
			hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
			var obj: Dictionary = k.duplicate()
			obj["line"] = int(line.value)
			obj["layer"] = 4
			obj["ori"] = k
			hold.obj = obj
			event.get_child(4).add_child(hold)
		return
	for i in 4 - l["event"].size():
		var new = Dictionary()
		new.set("alpha", Array())
		new.set("rotate", Array())
		new.set("speed", Array())
		new.set("x", Array())
		new.set("y", Array())
		l["event"].append(new)
	var e: Dictionary = l["event"].get(event_layer.value)
	for k in e["alpha"]:
		var hold := preload("res://event.tscn").instantiate()
		hold.beat = k["beat"]
		hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
		hold.easing = [ k["transition"], k["ease"] ]
		hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
		hold.type = 0
		hold.type_str = "alpha"
		hold.value = k["value"]
		hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
		hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
		var obj: Dictionary = k.duplicate()
		obj["line"] = int(line.value)
		obj["layer"] = int(event_layer.value)
		obj["ori"] = k
		hold.obj = obj
		event.get_child(0).add_child(hold)
	for k in e["rotate"]:
		var hold := preload("res://event.tscn").instantiate()
		hold.beat = k["beat"]
		hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
		hold.easing = [ k["transition"], k["ease"] ]
		hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
		hold.type = 1
		hold.type_str = "rotate"
		hold.value = k["value"]
		hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
		hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
		var obj: Dictionary = k.duplicate()
		obj["line"] = int(line.value)
		obj["layer"] = int(event_layer.value)
		obj["ori"] = k
		hold.obj = obj
		event.get_child(1).add_child(hold)
	for k in e["speed"]:
		var hold := preload("res://event.tscn").instantiate()
		hold.beat = k["beat"]
		hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
		hold.easing = [ 0, 0 ]
		hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
		hold.type = 2
		hold.type_str = "speed"
		hold.value = k["value"]
		hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
		hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
		var obj: Dictionary = k.duplicate()
		obj["line"] = int(line.value)
		obj["layer"] = int(event_layer.value)
		obj["ori"] = k
		hold.obj = obj
		event.get_child(2).add_child(hold)
	for k in e["x"]:
		var hold := preload("res://event.tscn").instantiate()
		hold.beat = k["beat"]
		hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
		hold.easing = [ k["transition"], k["ease"] ]
		hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
		hold.type = 3
		hold.type_str = "x"
		hold.value = k["value"]
		hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
		hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
		var obj: Dictionary = k.duplicate()
		obj["line"] = int(line.value)
		obj["layer"] = int(event_layer.value)
		obj["ori"] = k
		hold.obj = obj
		event.get_child(3).add_child(hold)
	for k in e["y"]:
		var hold := preload("res://event.tscn").instantiate()
		hold.beat = k["beat"]
		hold.bezier = k["bezier"] if k.has("bezier") and k["bezier"] else [0.0, 0.0, 0.0, 0.0]
		hold.easing = [ k["transition"], k["ease"] ]
		hold.time = [ Tools.beat_to_time(k["beat"].get(0)), Tools.beat_to_time(k["beat"].get(1)) ]
		hold.type = 4
		hold.type_str = "y"
		hold.value = k["value"]
		hold.size = Vector2(event.size.x / 8.0, (Tools.beat_to_float(k["beat"].get(1)) - Tools.beat_to_float(k["beat"].get(0))) * interval.value * size.y)
		hold.position = Vector2(event.size.x / 10.0, event.size.y - Tools.beat_to_float(k["beat"].get(0)) * interval.value * size.y)
		var obj: Dictionary = k.duplicate()
		obj["line"] = int(line.value)
		obj["layer"] = int(event_layer.value)
		obj["ori"] = k
		hold.obj = obj
		event.get_child(4).add_child(hold)
func _on_speed_value_changed(value: float) -> void:
	$Player/Music.pitch_scale = value
	$PanelContainer/VBoxContainer/Control/Operations/ScrollContainer/MarginContainer/VBoxContainer/SpeedLabel.text = tr("music_speed") + ": " + String.num(value)
func _on_note_gui_input(_event: InputEvent) -> void:
	if _event is InputEventScreenTouch and _event.is_pressed():
		for i in note.get_child_count():
			var c := note.get_child(i)
			if Rect2(c.position.x - c.size.x / 2.0, c.position.y - c.size.y, c.size.x, c.size.y * (2.0 if c.hold == 0.0 else 1.0)).has_point(_event.position):
				touched = true
	elif _event is InputEventScreenDrag:
		if not note_apply.selected.is_empty():
			pass
		dragged = true
	elif _event is InputEventScreenTouch and _event.is_released():
		touched = false
		if dragged:
			dragged = false
			return
		var beat: float = Tools.half_up((note.size.y - _event.position.y) * h_lines.value / interval.value / size.y) / h_lines.value
		var pos: float = _event.position.x / note.size.x if v_lines.value == 0 else Tools.half_up(_event.position.x / note.size.x * (v_lines.value + 1)) / (v_lines.value + 1)
		match Global.type:
			0:
				for i in note.get_child_count():
					var c := note.get_child(i)
					if Rect2(c.position.x - c.size.x / 2.0, c.position.y - c.size.y, c.size.x, c.size.y * (2.0 if c.hold == 0.0 else 1.0)).has_point(_event.position):
						if c.hold != 0.0:
							holding = c
							continue
						select_note(c)
						holding = null
						break
				if holding:
					select_note(holding)
					holding = null
			1:
				if holding:
					holding.queue_free()
					holding = null
				var dic := {"above":true,"alpha":(255.0)if(Global.settings["data"]=="rpe")else(1.0),"beat":Tools.float_to_beat(beat,int(h_lines.value)),"fake":false,"speed":1.0,"type":1,"visible":9999999.0,"wide":1.0,"x":(pos-0.5)*2.0*((675.0)if(Global.settings["data"]=="rpe")else(1.0)),"y":0.0}
				var obj := dic.duplicate()
				obj["line"] = int(line.value)
				obj["ori"] = dic
				Global.undo_redo.create_action("add_note")
				Global.undo_redo.add_do_method(func():
					Global.loaded["line"][obj["line"]]["note"].append(dic)
					$Player.reload()
					reload()
				)
				Global.undo_redo.add_undo_method(func():
					Global.loaded["line"][obj["line"]]["note"].erase(dic)
					$Player.reload()
					reload()
				)
				Global.undo_redo.commit_action()
			2:
				if holding:
					if beat > Tools.beat_to_float(holding.beat):
						var dic := {"above":true,"alpha":(255.0)if(Global.settings["data"]=="rpe")else(1.0),"beat":[holding.beat,Tools.float_to_beat(beat,int(h_lines.value))],"fake":false,"speed":1.0,"type":1,"visible":9999999.0,"wide":1.0,"x":holding.x,"y":0.0}
						var obj := dic.duplicate()
						obj["line"] = int(line.value)
						obj["ori"] = dic
						Global.undo_redo.create_action("add_note")
						Global.undo_redo.add_do_method(func():
							Global.loaded["line"][obj["line"]]["note"].append(dic)
							$Player.reload()
							reload()
						)
						Global.undo_redo.add_undo_method(func():
							Global.loaded["line"][obj["line"]]["note"].erase(dic)
							$Player.reload()
							reload()
						)
						Global.undo_redo.commit_action()
					holding.queue_free()
					holding = null
				else:
					var hold := preload("res://tap.tscn").instantiate()
					hold.editor = true
					hold.modulate = Color.AQUA
					hold.beat = Tools.float_to_beat(beat, int(h_lines.value))
					hold.x = (pos-0.5)*2.0*((675.0)if(Global.settings["data"]=="rpe")else(1.0))
					hold.time = Tools.float_to_time(beat)
					hold.position = Vector2(pos * note.size.x, note.size.y - beat * interval.value * size.y)
					hold.type = 1
					hold.z_index = 1
					note.add_child(hold)
					holding = hold
			3:
				if holding:
					holding.queue_free()
					holding = null
				var dic := {"above":true,"alpha":(255.0)if(Global.settings["data"]=="rpe")else(1.0),"beat":Tools.float_to_beat(beat,int(h_lines.value)),"fake":false,"speed":1.0,"type":2,"visible":9999999.0,"wide":1.0,"x":(pos-0.5)*2.0*((675.0)if(Global.settings["data"]=="rpe")else(1.0)),"y":0.0}
				var obj := dic.duplicate()
				obj["line"] = int(line.value)
				obj["ori"] = dic
				Global.undo_redo.create_action("add_note")
				Global.undo_redo.add_do_method(func():
					Global.loaded["line"][obj["line"]]["note"].append(dic)
					$Player.reload()
					reload()
				)
				Global.undo_redo.add_undo_method(func():
					Global.loaded["line"][obj["line"]]["note"].erase(dic)
					$Player.reload()
					reload()
				)
				Global.undo_redo.commit_action()
			4:
				if holding:
					holding.queue_free()
					holding = null
				var dic := {"above":true,"alpha":(255.0)if(Global.settings["data"]=="rpe")else(1.0),"beat":Tools.float_to_beat(beat,int(h_lines.value)),"fake":false,"speed":1.0,"type":3,"visible":9999999.0,"wide":1.0,"x":(pos-0.5)*2.0*((675.0)if(Global.settings["data"]=="rpe")else(1.0)),"y":0.0}
				var obj := dic.duplicate()
				obj["line"] = int(line.value)
				obj["ori"] = dic
				Global.undo_redo.create_action("add_note")
				Global.undo_redo.add_do_method(func():
					Global.loaded["line"][obj["line"]]["note"].append(dic)
					$Player.reload()
					reload()
				)
				Global.undo_redo.add_undo_method(func():
					Global.loaded["line"][obj["line"]]["note"].erase(dic)
					$Player.reload()
					reload()
				)
				Global.undo_redo.commit_action()
			5:
				for i in note.get_child_count():
					var c := note.get_child(i)
					if Rect2(c.position.x - c.size.x / 2.0, c.position.y - c.size.y, c.size.x, c.size.y * (2.0 if c.hold == 0.0 else 1.0)).has_point(_event.position):
						if c.hold != 0.0:
							holding = c
							continue
						var dic: Dictionary = c.obj
						Global.undo_redo.create_action("delete_note")
						Global.undo_redo.add_do_method(func():
							Global.loaded["line"].get(dic["line"])["note"].erase(dic["ori"])
							$Player.reload()
							reload()
						)
						Global.undo_redo.add_undo_method(func():
							Global.loaded["line"].get(dic["line"])["note"].append(dic["ori"])
							$Player.reload()
							reload()
						)
						Global.undo_redo.commit_action()
						holding = null
						break
				if holding:
					var dic: Dictionary = holding.obj
					Global.undo_redo.create_action("delete_note")
					Global.undo_redo.add_do_method(func():
						Global.loaded["line"].get(dic["line"])["note"].erase(dic["ori"])
						$Player.reload()
						reload()
					)
					Global.undo_redo.add_undo_method(func():
						Global.loaded["line"].get(dic["line"])["note"].append(dic["ori"])
						$Player.reload()
						reload()
					)
					Global.undo_redo.commit_action()
					holding = null
			6:
				paste(beat)
			7:
				paste(beat, true)
func _on_event_gui_input(_event: InputEvent) -> void:
	if _event is InputEventScreenDrag:
		dragged = true
	if _event is InputEventScreenTouch and _event.is_released():
		if dragged:
			dragged = false
			return
		var beat: float = Tools.half_up((event.size.y - _event.position.y) * h_lines.value / interval.value / size.y) / h_lines.value
		var type: int = max(1, min(5, int(Tools.half_up(_event.position.x / event.size.x * 6))))
		var type_str: String = ""
		match type:
			1:
				type_str = "alpha" if event_layer.value < 4 else "color"
			2:
				type_str = "rotate" if event_layer.value < 4 else "incline"
			3:
				type_str = "speed" if event_layer.value < 4 else "text"
			4:
				type_str = "x" if event_layer.value < 4 else "x"
			5:
				type_str = "y" if event_layer.value < 4 else "y"
		if Global.type == 5:
			var n := event.get_child(type - 1)
			for i in n.get_child_count():
				var c := n.get_child(i)
				if Rect2(c.position.x - c.size.x / 2.0, c.position.y - c.size.y, c.size.x, c.size.y).has_point(Vector2(event.size.x / 10.0, _event.position.y)):
					var dic: Dictionary = c.obj
					Global.undo_redo.create_action("delete_event")
					Global.undo_redo.add_do_method(func():
						if dic["layer"] < 4:
							Global.loaded["line"].get(dic["line"])["event"].get(dic["layer"])[type_str].erase(dic["ori"])
						else:
							Global.loaded["line"].get(dic["line"])["extra"][type_str].erase(dic["ori"])
						$Player.reload()
						reload()
					)
					Global.undo_redo.add_undo_method(func():
						if event_layer.value < 4:
							Global.loaded["line"].get(dic["line"])["event"].get(dic["layer"])[type_str].append(dic["ori"])
						else:
							Global.loaded["line"].get(dic["line"])["extra"][type_str].append(dic["ori"])
						$Player.reload()
						reload()
					)
					Global.undo_redo.commit_action()
					break
		elif Global.type > 5:
			paste(beat, Global.type == 7)
		elif Global.type == 0:
			var n := event.get_child(type - 1)
			for i in n.get_child_count():
				var c := n.get_child(i)
				if Rect2(c.position.x - c.size.x / 2.0, c.position.y - c.size.y, c.size.x, c.size.y).has_point(Vector2(event.size.x / 10.0, _event.position.y)):
					select_event(c)
					break
		else:
			if eventing:
				if beat > eventing.beat.get(0):
					type_str = eventing.type_str
					var dic: Dictionary = {"beat":[Tools.float_to_beat(eventing.beat.get(0),int(h_lines.value)),Tools.float_to_beat(beat,int(h_lines.value))],"ease":0,"transition":0,"value":[0.0,0.0]}
					var obj := dic.duplicate()
					obj["line"] = int(line.value)
					obj["layer"] = int(event_layer.value)
					obj["ori"] = dic
					Global.undo_redo.create_action("add_event")
					Global.undo_redo.add_do_method(func():
						if obj["layer"] < 4:
							Global.loaded["line"].get(obj["line"])["event"].get(obj["layer"])[type_str].append(dic)
						else:
							var value: Array = Array()
							match type_str:
								"color":
									value.append("ffffff")
									value.append("ffffff")
								"incline":
									value.append(0.0)
									value.append(0.0)
								"text":
									value.append("")
									value.append("")
								"x":
									value.append(1.0)
									value.append(1.0)
								"y":
									value.append(1.0)
									value.append(1.0)
							dic.set("value", value)
							Global.loaded["line"].get(obj["line"])["extra"][type_str].append(dic)
						Global.sort_chart()
						var e: int = Global.loaded["line"].get(obj["line"])["event"].get(obj["layer"])[type_str].find(dic) if obj["layer"] < 4 else Global.loaded["line"].get(obj["line"])["extra"][type_str].find(dic)
						if e != 0:
							var easing: int = 0
							var trans: int = 0
							var v = dic["value"].get(0)
							if e > 0:
								var last: Dictionary =  Global.loaded["line"].get(obj["line"])["event"].get(obj["layer"])[type_str].get(e - 1) if obj["layer"] < 4 else Global.loaded["line"].get(obj["line"])["extra"][type_str].get(e - 1)
								easing = last["ease"]
								trans = last["transition"]
								v = last["value"].get(1)
							dic.set("ease", easing)
							dic.set("transition", trans)
							dic.set("value", [v, v])
						$Player.reload()
						reload()
					)
					Global.undo_redo.add_undo_method(func():
						if obj["layer"] < 4:
							Global.loaded["line"].get(obj["line"])["event"].get(obj["layer"])[type_str].erase(dic)
						else:
							Global.loaded["line"].get(obj["line"])["extra"][type_str].erase(dic)
						$Player.reload()
						reload()
					)
					Global.undo_redo.commit_action()
				eventing.queue_free()
			elif not eventing:
				var selected := false
				var n := event.get_child(type - 1)
				for i in n.get_child_count():
					var c := n.get_child(i)
					if Rect2(c.position.x - c.size.x / 2.0, c.position.y - c.size.y, c.size.x, c.size.y).has_point(Vector2(event.size.x / 10.0, _event.position.y)):
						select_event(c)
						selected = true
						break
				if not selected:
					var hold := preload("res://event.tscn").instantiate()
					hold.texture = Global.skin["t"]["t"]
					hold.z_index = 1
					hold.modulate = Color.LIGHT_PINK
					hold.beat = [ beat, 0 ]
					hold.type = type - 1
					hold.type_str = type_str
					hold.time = [ Tools.float_to_time(beat), 0 ]
					hold.size = Vector2(event.size.x / 8.0, event.size.x / 8.0 / hold.texture.get_width() * hold.texture.get_height())
					hold.position = Vector2(event.size.x / 10.0, event.size.y - beat * interval.value * size.y + hold.size.y / 2.0)
					event.get_child(type - 1).add_child(hold)
					eventing = hold
func _on_progress_value_changed(value: float) -> void:
	var pos: float = 0.0
	for i in Global.bpm.size():
		var this: Dictionary = Global.bpm.get(i)
		var next = null if i == Global.bpm.size() - 1 else Global.bpm.get(i + 1)
		if not next or next["time"] > value:
			pos += (value - this["time"]) * this["bpm"]
			break
		pos += (next["time"] - this["time"]) * this["bpm"]
	pos *= size.y * interval.value / 60.0
	h_lines_scroll.scroll_vertical = int(h_lines_scroll_bar.max_value - h_lines_scroll_bar.page - fmod(pos, interval.value * size.y))
	scroll.scroll_vertical = int(scroll.get_v_scroll_bar().max_value - scroll.get_v_scroll_bar().page - pos)
	beats.scroll_vertical = scroll.scroll_vertical
	if not player.playing:
		player_progress.value = progress.value
func _on_line_id_toggled(toggled_on: bool) -> void:
	for i in $Player/MarginContainer/Control.get_children():
		if i.get_index() > line.max_value:
			return
		i.get_child(0).visible = toggled_on
func select_note(c: Node) -> void:
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Above.button_pressed = c.above
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Alpha.text = String.num(c.alpha)
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Beat/0".text = String.num_uint64(c.beat.get(0))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Beat/2".text = String.num_uint64(c.beat.get(1))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Beat/4".text = String.num_uint64(c.beat.get(2))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Beat2/0".text = String.num_uint64(c.endbeat.get(0))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Beat2/2".text = String.num_uint64(c.endbeat.get(1))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Beat2/4".text = String.num_uint64(c.endbeat.get(2))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Fake.button_pressed = c.fake
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Speed.text = String.num(c.speed)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Wide.text = String.num(c.wide)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/X.text = String.num(c.x)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Y.text = String.num(c.y)
	if c in $PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply.selected:
		c.modulate = Color.WHITE
		$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply.selected.erase(c)
	else:
		c.modulate = Color.LIGHT_GREEN
		$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Note/Apply.selected.append(c)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/OptionButton.select(3)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/OptionButton.item_selected.emit(3)
func select_event(c: Node) -> void:
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Type.selected = c.type if event_layer.value < 4 else c.type + 5
	var start: Array = c.beat.get(0)
	var end: Array = c.beat.get(1)
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Beat/0".text = String.num_uint64(start.get(0))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Beat/2".text = String.num_uint64(start.get(1))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Beat/4".text = String.num_uint64(start.get(2))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Beat2/0".text = String.num_uint64(end.get(0))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Beat2/2".text = String.num_uint64(end.get(1))
	$"PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Beat2/4".text = String.num_uint64(end.get(2))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Transition.select(c.easing.get(0))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Transition.item_selected.emit(c.easing.get(0))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Ease.select(c.easing.get(1))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Ease.item_selected.emit(c.easing.get(1))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Bezier.text = " ".join(PackedStringArray(Array(c.bezier)))
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Control.bezier = c.bezier
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Value.text = String.num(c.value.get(0)) if c.value.get(0) is float or c.value.get(0) is int else c.value.get(0)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Value2.text = String.num(c.value.get(1)) if c.value.get(1) is float or c.value.get(0) is int else c.value.get(1)
	if c in $PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply.selected:
		c.self_modulate = Color.WHITE
		$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply.selected.erase(c)
	else:
		c.self_modulate = Color.LIGHT_GREEN
		$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/Event/Apply.selected.append(c)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/OptionButton.select(4)
	$PanelContainer/VBoxContainer/Control/Properties/ScrollContainer/MarginContainer/VBoxContainer/OptionButton.item_selected.emit(4)
func paste(beat: float, reverse: bool = false) -> bool:
	if not DisplayServer.clipboard_has():
		Global.make_notification(tr("no_valid_clip"))
		return false
	var clip: String = DisplayServer.clipboard_get()
	if not clip.begins_with("[") or not clip.ends_with("]"):
		Global.make_notification(tr("no_valid_clip"))
		return false
	var json = JSON.parse_string(DisplayServer.clipboard_get())
	if not json or json is not Array or json.get(0) is not Array or json.get(0).size() != 3 or json.get(0).get(0) != "PhiatorClient" or json.get(0).get(1) != "DingZiHu" or json.get(0).get(2) is not float:
		Global.make_notification(tr("no_valid_clip"))
		return false
	Global.undo_redo.create_action("paste")
	var b := Tools.float_to_beat(beat, int(h_lines.value))
	var e: int = 0
	var n: int = 0
	for i in json:
		if not i or i is not Array:
			continue
		if i.get(0) == "e":
			var v1 = i.get(4).get(0)
			var v2 = i.get(4).get(1)
			if i.get(5):
				if event_layer.value == 4:
					Global.make_notification(tr("no_valid_clip"))
					Global.undo_redo.commit_action(false)
					return false
				var dic := {"beat":[Tools.beat_add(i.get(1).get(0),b),Tools.beat_add(i.get(1).get(1),b)],"ease":i.get(2).get(1),"transition":i.get(2).get(0),"value":[(-v1)if(((i.get(3)=="rotate")or(i.get(3)=="x")or(i.get(3)=="y"))and(v1 is float)and(reverse))else(v1),(-v2)if(((i.get(3)=="rotate")or(i.get(3)=="x")or(i.get(3)=="y"))and(v2 is float)and(reverse))else(v2)]}
				var obj := {"line":line.value,"layer":event_layer.value,"ori":dic}
				Global.undo_redo.add_do_method(func():
					Global.loaded["line"].get(obj["line"])["event"].get(obj["layer"])[i.get(3)].append(dic)
				)
				Global.undo_redo.add_undo_method(func():
					Global.loaded["line"].get(obj["line"])["event"].get(obj["layer"])[i.get(3)].erase(dic)
				)
			else:
				if event_layer.value < 4:
					Global.make_notification(tr("no_valid_clip"))
					Global.undo_redo.commit_action(false)
					return false
				var dic := {"beat":[Tools.beat_add(i.get(1).get(0),b),Tools.beat_add(i.get(1).get(1),b)],"ease":i.get(2).get(1),"transition":i.get(2).get(0),"value":[(-v1)if((i.get(3)=="incline")and(v1 is float)and(reverse))else(v1),(-v2)if((i.get(3)=="incline")and(v2 is float)and(reverse))else(v2)]}
				var obj := {"line":line.value,"layer":event_layer.value,"ori":dic}
				Global.undo_redo.add_do_method(func():
					Global.loaded["line"].get(obj["line"])["extra"][i.get(3)].append(dic)
				)
				Global.undo_redo.add_undo_method(func():
					Global.loaded["line"].get(obj["line"])["extra"][i.get(3)].erase(dic)
				)
			e += 1
		elif i.get(0) == "n":
			var x: float = i.get(9)
			var dic := {"above":i.get(2),"alpha":i.get(3),"beat":Tools.beat_add(i.get(1).get(0),b)if(Tools.compare_beat(i.get(1).get(0),i.get(1).get(1))==0)else[Tools.beat_add(i.get(1).get(0),b),Tools.beat_add(i.get(1).get(1),b)],"fake":i.get(4),"speed":i.get(5),"type":int(i.get(6)),"visible":i.get(7),"wide":i.get(8),"x":(-x)if(reverse)else(x),"y":i.get(10)}
			var obj := {"line":line.value,"ori":dic}
			Global.undo_redo.add_do_method(func():
				Global.loaded["line"].get(obj["line"])["note"].append(dic)
			)
			Global.undo_redo.add_undo_method(func():
				Global.loaded["line"].get(obj["line"])["note"].erase(dic)
			)
			n += 1
	Log.i("Pasted %s events and %s notes at %s. Reverse: %s" % [e, n, b, reverse])
	Global.undo_redo.add_do_method(func():
		$Player.reload()
		reload()
	)
	Global.undo_redo.add_undo_method(func():
		$Player.reload()
		reload()
	)
	Global.undo_redo.commit_action()
	Global.make_notification(tr("done"))
	return true
