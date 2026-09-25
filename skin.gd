extends HBoxContainer

var path: String = "res://respack/PhiatorOfficial.zip"
var skin: Dictionary = {"c":["feffa9","a2eeff"],"hx":[],"hxs":1.0,"p":true,"s":{},"t":{}}
func _ready() -> void:
	var load_image := func(data: PackedByteArray, file: String) -> Image:
		var i := Image.new()
		match file.get_extension().to_lower():
			"png":
				i.load_png_from_buffer(data)
			"webp":
				i.load_webp_from_buffer(data)
		return i
	var load_sound := func(data: PackedByteArray, file: String) -> AudioStream:
		var s: AudioStream
		match file.get_extension().to_lower():
			"mp3":
				s = AudioStreamMP3.load_from_buffer(data)
			"ogg":
				s = AudioStreamOggVorbis.load_from_buffer(data)
			"wav":
				s = AudioStreamWAV.load_from_buffer(data)
		return s
	var zr := ZIPReader.new()
	zr.open(path)
	var info: Dictionary = JSON.parse_string(zr.read_file("info.json").get_string_from_utf8())
	skin.set("c", info["color"] if info.has("color") else [ "feffa9", "a2eeff" ])
	skin.set("hxs", info["hitFx"].get(2) if info["hitFx"].size() == 3 else 1.0)
	skin.set("p", info["particles"] if info.has("particles") else true)
	for i in zr.get_files():
		var n := i.to_lower().split(".")
		match n.get(0):
			"click":
				match n.get(1):
					"png", "webp":
						skin["t"].set("t", ImageTexture.create_from_image(load_image.call(zr.read_file(i), i)))
					"mp3", "ogg", "wav":
						skin["s"].set("c", load_sound.call(zr.read_file(i), i))
			"drag":
				match n.get(1):
					"png", "webp":
						skin["t"].set("d", ImageTexture.create_from_image(load_image.call(zr.read_file(i), i)))
					"mp3", "ogg", "wav":
						skin["s"].set("d", load_sound.call(zr.read_file(i), i))
			"flick":
				match n.get(1):
					"png", "webp":
						skin["t"].set("f", ImageTexture.create_from_image(load_image.call(zr.read_file(i), i)))
					"mp3", "ogg", "wav":
						skin["s"].set("f", load_sound.call(zr.read_file(i), i))
			"hit_fx":
				var hx := ImageTexture.create_from_image(load_image.call(zr.read_file(i), i))
				var fs := Vector2(hx.get_width() / info["hitFx"].get(1), hx.get_height() / info["hitFx"].get(0))
				for r in info["hitFx"].get(0):
					for c in info["hitFx"].get(1):
						var at := AtlasTexture.new()
						at.atlas = hx
						at.region = Rect2(c * fs.x, r * fs.y, fs.x, fs.y)
						skin["hx"].append(at)
			"hold":
				var h := ImageTexture.create_from_image(load_image.call(zr.read_file(i), i))
				skin["t"].set("h", h)
				var hel: float = info["hold"].get(0).get(0)
				var hhl: float = info["hold"].get(0).get(1)
				var he := AtlasTexture.new()
				he.atlas = h
				he.region = Rect2(0.0, 0.0, h.get_width(), hel)
				skin["t"].set("he", he)
				var hb := AtlasTexture.new()
				hb.atlas = h
				hb.region = Rect2(0.0, hel, h.get_width(), h.get_height() - hel - hhl)
				skin["t"].set("hb", hb)
				var hh := AtlasTexture.new()
				hh.atlas = h
				hh.region = Rect2(0.0, h.get_height() - hhl, h.get_width(), hhl)
				skin["t"].set("hh", hh)
			"click_mh":
				skin["t"].set("tm", ImageTexture.create_from_image(load_image.call(zr.read_file(i), i)))
			"drag_mh":
				skin["t"].set("dm", ImageTexture.create_from_image(load_image.call(zr.read_file(i), i)))
			"flick_mh":
				skin["t"].set("fm", ImageTexture.create_from_image(load_image.call(zr.read_file(i), i)))
			"hold_mh":
				var h := ImageTexture.create_from_image(load_image.call(zr.read_file(i), i))
				skin["t"].set("hm", h)
				var hel: float = info["hold"].get(1).get(0)
				var hhl: float = info["hold"].get(1).get(1)
				var he := AtlasTexture.new()
				he.atlas = h
				he.region = Rect2(0.0, 0.0, h.get_width(), hel)
				skin["t"].set("hem", he)
				var hb := AtlasTexture.new()
				hb.atlas = h
				hb.region = Rect2(0.0, hel, h.get_width(), h.get_height() - hel - hhl)
				skin["t"].set("hbm", hb)
				var hh := AtlasTexture.new()
				hh.atlas = h
				hh.region = Rect2(0.0, h.get_height() - hhl, h.get_width(), hhl)
				skin["t"].set("hhm", hh)
	zr.close()
	$Text/Label.text = tr("skins_name") + info["name"] + "\n" + ((tr("skins_author") + info["author"] + "\n") if info.has("author") else "") + ((tr("skins_description") + info["description"]) if info.has("description") else "")
	$"VBoxContainer/Tap/1".texture = skin["t"]["t"]
	$"VBoxContainer/Tap/2".texture = skin["t"]["tm"]
	$"VBoxContainer/Flick/1".texture = skin["t"]["f"]
	$"VBoxContainer/Flick/2".texture = skin["t"]["fm"]
	$"VBoxContainer/Drag/1".texture = skin["t"]["d"]
	$"VBoxContainer/Drag/2".texture = skin["t"]["dm"]
	$"Hold/1/End".texture = skin["t"]["he"]
	$"Hold/1/Body".texture = skin["t"]["hb"]
	$"Hold/1/Head".texture = skin["t"]["hh"]
	$"Hold/2/End".texture = skin["t"]["hem"]
	$"Hold/2/Body".texture = skin["t"]["hbm"]
	$"Hold/2/Head".texture = skin["t"]["hhm"]
