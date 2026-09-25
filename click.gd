extends TextureRect

var above: bool = true
var alpha: float = 1.0
var beat: Array = [ 0, 0, 1 ]
var finish: bool = true
var editor: bool = false
var endbeat: Array = beat
var fake: bool = false
var hit: bool = true
var hold: float = 0.0
var last_finish: bool = false
var speed: float = 1.0
var time: float = 0.0
var type: int = 0
var visible_time: float = 9999999.0
var wide: float = 1.0
var x: float = 0.0
var y: float = 0.0
var length: float = 0.0
var py: float = 0.0
var sound: AudioStreamPlayer
var player: AspectRatioContainer
var control: Control
var line: TextureRect
var music: AudioStreamPlayer
var combo: Label
var progress: ProgressBar
var timer: Timer
var head: TextureRect
var end: TextureRect
var obj: Dictionary
var multiple: bool = false
var multiple_rate: float = 0.0
var text: String
func _ready() -> void:
	sound = $AudioStreamPlayer
	sound.volume_linear = Global.settings["se"]
	match type:
		1:
			if hold != 0.0:
				head = $Head
				end = $End
				texture = Global.skin["t"]["hbm" if multiple else "hb"]
				head.texture = Global.skin["t"]["hhm" if multiple else "hh"]
				end.texture = Global.skin["t"]["hem" if multiple else "he"]
				text = "hb"
			else:
				texture = Global.skin["t"]["tm" if multiple else "t"]
				text = "t"
			sound.stream = Global.skin["s"]["c"]
		2:
			texture = Global.skin["t"]["fm" if multiple else "f"]
			text = "f"
			sound.stream = Global.skin["s"]["f"]
		3:
			texture = Global.skin["t"]["dm" if multiple else "d"]
			text = "d"
			sound.stream = Global.skin["s"]["d"]
	if !editor:
		player = $"../../../.."
		control = $"../.."
		line = $".."
		music = $"../../../../Music"
		combo = $"../../Number"
		progress = $"../../Progress"
		py = 0
		for i in line.event:
			var l: Array = i.get(2)
			for j in l.size():
				var k: Dictionary = l.get(j)
				var last = null
				if j > 0:
					last = l.get(j - 1)
				var ktime: Array = k["time"]
				var kvalue: float = k["value"]
				var kdelta: float = k["delta"]
				if ktime.get(1) < time:
					py += (ktime.get(1) - ktime.get(0)) * (kvalue * 2.0 + kdelta) / 2.0
					if j > 0:
						py += (ktime.get(0) - last["time"].get(1)) * (last["value"] + last["delta"])
					if j == l.size() - 1:
						py += (time - ktime.get(1)) * (kvalue + kdelta)
				elif ktime.get(0) > time:
					if j > 0:
						py += (time - last["time"].get(1)) * (last["value"] + last["delta"])
					break
				else:
					py += (time - ktime.get(0)) * (kvalue * 2.0 + kdelta * (time - ktime.get(0)) / (ktime.get(1) - ktime.get(0))) / 2.0
					if j > 0:
						py += (ktime.get(0) - last["time"].get(1)) * (last["value"] + last["delta"])
					break
		length = 0
		for i in line.event:
			for j in i.get(2).size():
				var k = i.get(2).get(j)
				var last = null
				if j > 0:
					last = i.get(2).get(j - 1)
				if k["time"].get(1) < time + hold:
					length += (k["time"].get(1) - k["time"].get(0)) * (k["value"] * 2 + k["delta"]) / 2
					if j > 0:
						length += (k["time"].get(0) - last["time"].get(1)) * (last["value"] + last["delta"])
					if j == i.get(2).size() - 1:
						length += (time + hold - k["time"].get(1)) * (k["value"] + k["delta"])
				elif k["time"].get(0) > time + hold:
					if j > 0:
						length += (time + hold - last["time"].get(1)) * (last["value"] + last["delta"])
					break
				else:
					length += (time + hold - k["time"].get(0)) * (k["value"] * 2 + k["delta"] * (time + hold - k["time"].get(0)) / (k["time"].get(1) - k["time"].get(0))) / 2
					if j > 0:
						length += (k["time"].get(0) - last["time"].get(1)) * (last["value"] + last["delta"])
					break
		length -= py
		modulate.a = alpha
		if hold != 0.0:
			timer = $Timer
			timer.timeout.connect(judge.bind(true))
		if not above:
			rotation_degrees = 180.0
		multiple_rate = (float(Global.skin["t"]["%sm" % text].get_width()) / float(Global.skin["t"][text].get_width())) if multiple else 1.0
		await get_tree().process_frame
		size.x = player.size.x / 8.0 * wide * multiple_rate
		size.y = (size.x / wide / texture.get_width() * texture.get_height()) if hold == 0.0 else (hold * speed * player.size.y)
	else:
		size.x = get_parent().size.x / 6.0
		if hold == 0.0:
			size.y = get_parent().size.x / 6.0 / texture.get_width() * texture.get_height()
		set_process(false)
		set_process_internal(false)
		set_physics_process(false)
		set_physics_process_internal(false)
func _process(_delta: float) -> void:
	if progress.value >= time:
		if player.mode > 0 or fake:
			judge(false)
			if hold != 0.0:
				head.visible = false
				size.y = (py + length - line.speed) * speed * control.size.y
				if progress.value > time + hold:
					timer.stop()
				elif timer.is_stopped():
					timer.start()
	else:
		hit = false
		if hold != 0.0:
			head.visible = true
			size.y = length * speed * control.size.y
			timer.stop()
	modulate.a = 0.0 if line.values.get(0) < 0.0 else alpha
	finish = progress.value >= time + hold
	if last_finish != finish:
		if hold != 0.0:
			end.visible = not finish
		if not fake:
			combo.text = String.num_int64(int(combo.text) + (1 if finish else -1))
		last_finish = finish
	position = Vector2((x * control.size.x + line.size.x) / 2.0, 0.0 if hold != 0.0 and hit else (py - line.speed - y) * (-speed if above else speed) * control.size.y)
	visible = (not hit or hold != 0.0) and ((line.cover and (position.y < 1.0 - y * speed * control.size.y if above else position.y > -1.0 + y * speed * control.size.y)) or progress.value >= time) and progress.value >= time - visible_time
func judge(h: bool = false) -> void:
	if music.playing and not fake:
		if hit and not h:
			return
		if not hit:
			sound.play()
		var hfx := preload("res://hit.tscn").instantiate()
		hfx.position.x = line.position.x + (position.x - line.size.x / 2.0) * cos(line.rotation)
		hfx.position.y = line.position.y + (position.x - line.size.x / 2.0) * sin(line.rotation)
		hfx.size.x = size.x / multiple_rate * Global.skin["hxs"]
		hfx.size.y = hfx.size.x
		hfx.self_modulate = Color.from_string(Global.skin["c"].get(0), Color.WHITE)
		control.add_child(hfx)
		control.move_child(hfx, -8)
	hit = true
