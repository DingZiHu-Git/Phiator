## Global variables and functions.
extends Node

## Used to confirm if the chart is edited by newer version of Phiator.
const VER: int = 34
## Used to convert event easing types between RPE format and Phiator format.
const RPE_EASINGS_MAPPING: Array[Array] = [[0,0],[1,1],[1,0],[4,1],[4,0],[1,2],[4,2],[7,1],[7,0],[3,1],[3,0],[7,2],[3,2],[2,1],[2,0],[5,1],[5,0],[8,1],[8,0],[10,1],[10,0],[8,2],[10,2],[6,1],[6,0],[9,1],[9,0],[6,2],[9,2]]
## Storage path. All files will be stored in the path.
var DIR: String = ""
## Separator char.
const SEPARATOR: String = "/"
## The dictionary used to store values of settings.
var settings: Dictionary
## Default settings. Used to store default values of each setting item.[br]
## The [code]save_settings[/code] function also uses the values in it. So the order of the items is very important.
const default_settings: Array[Array] = [["music", 1], ["se", 1], ["notificationTime", 3], ["background", 1], ["blur", true], ["black", 0.6], ["data", "phiator"], ["autoSave", 60], ["history", 100], ["safeZone", 1.0], ["interfaceScale", 1.0]]
## The dictionary used to store values of properties.
var properties: Dictionary
## Default properties. Used to store default values of each property item.[br]
## The [code]save_properties[/code] function also uses the values in it. So the order of the items is very important.
const default_properties: Array[Array] = [["lineID", true], ["hLines", 4], ["vLines", 21], ["interval", 0.5]]
## A temp variable used to store which chart is selected.
var path: String
## Used in editor to sign which action is selected.[br]
## For example, [code]0[/code] means "Select", [code]1[/code] means "Tap", [code]5[/code] means "Delete" and [code]6[/code] means "Paste".
var type: int = 0
## Used in editor to sign which mode is selected.[br]
## For example, [code]0[/code] means "Note&Event", [code]1[/code] means "Note" and [code]2[/code] means "Event".
var mode: int = 0
## The stream used to store the data of the music in the chart.
var stream: AudioStream
## The dictionary used to store the info of the chart.
var info: Dictionary
## The dictionary used to store the loaded chart.
var loaded: Dictionary
## The dictionary used to store the loaded skin.
var skin: Dictionary = {"c":["feffa9","a2eeff"],"hx":[],"hxs":1.0,"p":true,"s":{},"t":{}}
## The array used to store the calculated bpm list of the loaded chart.
var bpm: Array
## The node used to show toast notifications.
var notifications: Node
## The label used to show FPS.
var fps: Label
## Showed tip count.
var tip: int = 0
## (I forgot what is its function)[br]
## (Forgive me pls)
var selected: int = 0
## The UndoRedo object used in editor.
var undo_redo: UndoRedo
func _ready() -> void:
	# Print log head
	Log.i("APP VERSION: " + String.num_uint64(VER))
	Log.i("OS NAME: " + OS.get_name())
	Log.i("OS MODEL: " + OS.get_model_name())
	Log.i("OS VERSION: " + OS.get_version_alias())
	# Set DIR
	DIR = Tools.get_android_activity().getExternalFilesDir("").getAbsolutePath() + "/" if OS.get_name() == "Android" else "user://"
	if OS.has_feature("editor"):
		DIR = "/storage/emulated/0/Android/data/org.godotengine.editor.v4/files/" + ProjectSettings.get_setting("application/config/name") + "/"
	DirAccess.make_dir_recursive_absolute(DIR + "cache") #Create cache dir
	if FileAccess.file_exists(DIR + "resources.dat"):
		DirAccess.remove_absolute(DIR + "resources.dat") #Delete old Phiator pass code file
	ShareFile.file_received.connect(import_chart) #Connect plugin signal (Not finished yet)
func _process(_delta: float) -> void:
	if fps:
		fps.text = "FPS: " + String.num_uint64(int(Engine.get_frames_per_second()))
## Read settings file then move the data into [code]settings[/code] dictionary.
func get_settings() -> void:
	Log.i("Getting settings...")
	if not FileAccess.file_exists(DIR + SEPARATOR + "settings.json"):
		Log.w("Settings file doesn't exist. Creating...")
		var temp := FileAccess.open(DIR + SEPARATOR + "settings.json", FileAccess.WRITE)
		temp.store_string(JSON.stringify({}))
		temp.close()
	var fa := FileAccess.open(DIR + SEPARATOR + "settings.json", FileAccess.READ)
	settings = JSON.parse_string(fa.get_as_text())
	fa.close()
	for i in default_settings:
		if not settings.has(i.get(0)):
			Log.w("Setting " + i.get(0) + " doesn't exist. Setting to the default value: " + str(i.get(1)))
			settings.set(i.get(0), i.get(1))
## Save settings.[br]
## [code]args[/code]: The value of each setting item. For the order, please check [code]default_settings[/code] array.
func save_settings(...args) -> void:
	Log.i("Saving settings...")
	for i in default_settings.size():
		settings.set(default_settings.get(i).get(0), args.get(i))
	var fa = FileAccess.open(DIR + SEPARATOR + "settings.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(settings))
	fa.close()
## Make toast notification with the given text.[br]
## [code]text[/code]: The text you want to display in the toast notification.
func make_notification(text: String) -> void:
	var n: PanelContainer = preload("res://notification.tscn").instantiate()
	n.get_child(0).text = text
	for i in notifications.get_child_count():
		var no: PanelContainer = notifications.get_child(i)
		no.index += 1
		no.easing = 0
	notifications.add_child(n)
## Import chart in the given path.[br]
## [code]p[/code]: Chart path. It's a content uri returned by SAF on Android.
func import_chart(p: String) -> void:
	Log.i("Importing chart...")
	var zr := ZIPReader.new()
	zr.open(p)
	for i in zr.get_files():
		var strs := i.split("/")
		var fa := FileAccess.open(OS.get_cache_dir() + SEPARATOR + strs.get(strs.size() - 1), FileAccess.WRITE)
		fa.store_buffer(zr.read_file(i))
		fa.close()
	zr.close()
	var da := DirAccess.open(OS.get_cache_dir())
	da.include_hidden = true
	var found := false
	for i in da.get_files():
		var lower := i.to_lower()
		if lower == "info.json":
			var fa := FileAccess.open(OS.get_cache_dir() + SEPARATOR + i, FileAccess.READ)
			path = JSON.parse_string(fa.get_as_text())["path"]
			fa.close()
			found = true
		elif lower == "info.txt":
			var fa := FileAccess.open(OS.get_cache_dir() + SEPARATOR + i, FileAccess.READ)
			var strs := fa.get_as_text().split("\n")
			fa.close()
			info = Dictionary()
			info.set("artist", "")
			info.set("author", "")
			info.set("chart", "")
			info.set("format", "phiator")
			info.set("illustration", "")
			info.set("illustrator", "")
			info.set("lastEdit", VER)
			info.set("level", "")
			info.set("music", "")
			info.set("offset", 0)
			info.set("path", "")
			var temp: String = ""
			var result := Dictionary()
			for j in strs:
				if j.to_lower().begins_with("composer:"):
					info.set("artist", j.substr(j.find(":") + 1).strip_edges())
				elif j.to_lower().begins_with("chart:"):
					temp = j.substr(j.find(":") + 1).strip_edges()
					fa = FileAccess.open(OS.get_cache_dir() + SEPARATOR + j.substr(j.find(":") + 1).strip_edges(), FileAccess.READ)
					if fa == null:
						make_notification(error_string(FileAccess.get_open_error()))
						return
					var json = JSON.parse_string(fa.get_as_text())
					fa.close()
					if json == null or not (json.has("META") and json.get("META").has("RPEVersion")):
						make_notification(tr("unsupported_format"))
						return
					var array := Array()
					for k in json["BPMList"]:
						array.append({"beat":[int(k["startTime"].get(0)),int(k["startTime"].get(1)),int(k["startTime"].get(2))],"bpm":k["bpm"]})
					result.set("bpm", array)
					array = Array()
					info.set("offset", int(json["META"]["offset"]))
					for k in json["judgeLineList"]:
						var dic: Dictionary = Dictionary()
						dic.set("bpmFactor", k["bpmfactor"] if k.has("bpmfactor") else 1.0)
						dic.set("cover", bool(k["isCover"]) if k.has("cover") else true)
						var arra: Array = Array()
						for l in k["eventLayers"]:
							if l == null:
								continue
							var di: Dictionary = Dictionary()
							var arr: Array = Array()
							if l.has("alphaEvents"):
								for m in l["alphaEvents"]:
									arr.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[m["start"]/255,m["end"]/255]})
							di.set("alpha", arr)
							arr = Array()
							if l.has("rotateEvents"):
								for m in l["rotateEvents"]:
									arr.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[m["start"],m["end"]]})
							di.set("rotate", arr)
							arr = Array()
							if l.has("speedEvents"):
								for m in l["speedEvents"]:
									arr.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1)if(m.has("easingType"))else(0),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0)if(m.has("easingType"))else(0),"value":[m["start"]*120.0/900.0,m["end"]*120.0/900.0]})
							di.set("speed", arr)
							arr = Array()
							if l.has("moveXEvents"):
								for m in l["moveXEvents"]:
									arr.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[m["start"]/675.0,m["end"]/675.0]})
							di.set("x", arr)
							arr = Array()
							if l.has("moveYEvents"):
								for m in l["moveYEvents"]:
									arr.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[m["start"]/-450.0,m["end"]/-450.0]})
							di.set("y", arr)
							arra.append(di)
						dic.set("event", arra)
						if k.has("extended"):
							var l: Dictionary = k["extended"]
							var di: Dictionary = Dictionary()
							arra = Array()
							if l.has("colorEvents"):
								for m in l["colorEvents"]:
									arra.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[Color.from_rgba8(int(m["start"].get(0)),int(m["start"].get(1)),int(m["start"].get(2))).to_html(false),Color.from_rgba8(int(m["end"].get(0)),int(m["end"].get(1)),int(m["end"].get(2))).to_html(false)]})
							di.set("color", arra)
							arra = Array()
							if l.has("inclineEvents"):
								for m in l["inclineEvents"]:
									arra.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(1).get(1),"transition":RPE_EASINGS_MAPPING.get(1).get(0),"value":[m["start"],m["end"]]})
							di.set("incline", arra)
							arra = Array()
							if l.has("textEvents"):
								for m in l["textEvents"]:
									arra.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1)if(m.has("easingType"))else(0),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0)if(m.has("easingType"))else(0),"value":[m["start"],m["end"]]})
							di.set("text", arra)
							arra = Array()
							if l.has("scaleXEvents"):
								for m in l["scaleXEvents"]:
									arra.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[m["start"],m["end"]]})
							di.set("x", arra)
							arra = Array()
							if l.has("scaleYEvents"):
								for m in l["scaleYEvents"]:
									arra.append({"beat":[[int(m["startTime"].get(0)),int(m["startTime"].get(1)),int(m["startTime"].get(2))],[int(m["endTime"].get(0)),int(m["endTime"].get(1)),int(m["endTime"].get(2))]],"bezier":(m["bezierPoints"]if((m.has("bezier"))and(m["bezier"]==1.0))else(null)),"ease":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(1),"transition":RPE_EASINGS_MAPPING.get(int(m["easingType"])-1).get(0),"value":[m["start"],m["end"]]})
							di.set("y", arra)
							dic.set("extra", di)
						dic.set("father", int(k["father"]) if k.has("father") else -1)
						arra = Array()
						if k.has("notes"):
							for l in k["notes"]:
								arra.append({"above":l["above"]==1.0,"alpha":(l["alpha"]if(l.has("alpha"))else(255.0))/255,"beat":[int(l["startTime"].get(0)),int(l["startTime"].get(1)),int(l["startTime"].get(2))]if(l["type"]!=2)else[[int(l["startTime"].get(0)),int(l["startTime"].get(1)),int(l["startTime"].get(2))],[int(l["endTime"].get(0)),int(l["endTime"].get(1)),int(l["endTime"].get(2))]],"fake":bool(l["isFake"]),"speed":(l["speed"]if(l.has("speed"))else(1.0)),"type":(1)if(int(l["type"])<3)else(int(l["type"])-1),"visible":(l["visibleTime"])if(l.has("visibleTime"))else(9999999.0),"wide":(l["size"]if(l.has("size"))else(1.0)),"x":l["positionX"]/675.0,"y":l["yOffset"]/900.0})
						dic.set("note", arra)
						dic.set("texture", k["Texture"]if(k["Texture"]!="line.png")else(""))
						dic.set("ui", 0)
						dic.set("z", int(k["zOrder"]) if k.has("zOrder") else 0)
						array.append(dic)
					result.set("line", array)
				elif j.to_lower().begins_with("charter:"):
					info.set("author", j.substr(j.find(":") + 1).strip_edges())
				elif j.to_lower().begins_with("path:"):
					path = j.substr(j.find(":") + 1).strip_edges()
					info.set("path", path)
					DirAccess.make_dir_recursive_absolute(DIR + SEPARATOR + path)
				elif j.to_lower().begins_with("picture:"):
					info.set("illustration", j.substr(j.find(":") + 1).strip_edges())
				elif j.to_lower().begins_with("illustrator:"):
					info.set("illustrator", j.substr(j.find(":") + 1).strip_edges())
				elif j.to_lower().begins_with("level:"):
					info.set("level", j.substr(j.find(":") + 1).strip_edges())
				elif j.to_lower().begins_with("name:"):
					info.set("chart", j.substr(j.find(":") + 1).strip_edges())
				elif j.to_lower().begins_with("song:"):
					info.set("music", j.substr(j.find(":") + 1).strip_edges())
			fa = FileAccess.open(DIR + SEPARATOR + path + SEPARATOR + path + ".json", FileAccess.WRITE)
			fa.store_string(JSON.stringify(result))
			fa.close()
			fa = FileAccess.open(DIR + SEPARATOR + path + SEPARATOR + "info.json", FileAccess.WRITE)
			fa.store_string(JSON.stringify(info))
			fa.close()
			da.remove(temp)
			da.remove(i)
			found = true
	if found:
		for i in da.get_files():
			DirAccess.copy_absolute(OS.get_cache_dir() + SEPARATOR + i, DIR + SEPARATOR + path + SEPARATOR + i)
		make_notification(tr("done"))
	else:
		make_notification(tr("unsupported_format"))
	Tools.clear_folder(OS.get_cache_dir())
## Export selected chart.[br]
## [code]format[/code]: The format string that user want to export to. Only [code]phiator[/code] and [code]rpe[/code] currently.[br]
## [code]p[/code]: The path that user specified to export the chart to. It's a content uri returned by SAF on Android.[br]
## [code]id[/code]: The chart identifer of the exported chart. Only used when copy chart.
func export_chart(format: String, p: String, id: String = "", share: bool = true) -> Error:
	Log.i("Exporting chart...")
	load_chart()
	if not id.is_empty():
		info["path"] = id
	var rpeev: bool = info["format"] == "rpe"
	var result := Dictionary()
	var rpe := format == "rpe"
	if rpe:
		var array := Array()
		for i in loaded["bpm"]:
			array.append({"bpm":i["bpm"],"startTime":i["beat"]})
		result.set("BPMList", array)
		result.set("META", {"RPEVersion":140,"background":info["illustration"],"charter":info["author"],"composer":info["artist"],"id":info["path"],"illustration":info["illustrator"],"level":info["level"],"name":info["chart"],"offset":info["offset"],"song":info["music"]})
		result.set("judgeLineGroup", ["Phiator"])
		array = Array()
		for i in loaded["line"]:
			var line := Dictionary()
			line.set("Group", 0)
			line.set("Name", "Untitled")
			line.set("Texture", "line.png" if i["texture"].is_empty() else i["texture"])
			line.set("alphaControl", [{"alpha":1.0,"easing":1,"x":0.0},{"alpha":1.0,"easing":1,"x":9999999.0}])
			var ui = null
			if line.has("ui"): match line["ui"]:
				1:
					ui = "pause"
				2:
					ui = "bar"
				3:
					ui = "combonumber"
				4:
					ui = "combo"
				5:
					ui = "score"
				6:
					ui = "name"
				7:
					ui = "level"
			line.set("attachUI", ui)
			line.set("bpmfactor", i["bpmFactor"])
			var arra := Array()
			for j in i["event"]:
				var dic := Dictionary()
				var arr := Array()
				for k in j["alpha"]:
					if k["ease"] == Tween.EaseType.EASE_OUT_IN:
						var ht := Tools.beat_add(k["beat"].get(0), Tools.beat_divide(Tools.beat_subtract(k["beat"].get(1), k["beat"].get(0)), [2, 0, 1]))
						var hv: float = k["value"].get(0) + (k["value"].get(1) - k["value"].get(0)) / 2.0
						var di1 := Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						var easing1: int = 1
						for l in RPE_EASINGS_MAPPING.size():
							if [k["transition"],Tween.EaseType.EASE_IN_OUT] == RPE_EASINGS_MAPPING.get(l):
								easing1 = l - 2
						di1.set("easingType", easing1)
						di1.set("end", int(hv) if rpeev else int(Tools.half_up(hv * 255.0)))
						di1.set("endTime", ht)
						di1.set("linkgroup", 0)
						di1.set("start", int(k["value"].get(0)) if rpeev else int(Tools.half_up(k["value"].get(0) * 255.0)))
						di1.set("startTime", k["beat"].get(0))
						arr.append(di1)
						di1 = Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						if easing1 > 1:
							easing1 += 1
						di1.set("easingType", easing1)
						di1.set("end", int(k["value"].get(1)) if rpeev else int(Tools.half_up(k["value"].get(1) * 255.0)))
						di1.set("endTime", k["beat"].get(1))
						di1.set("linkgroup", 0)
						di1.set("start", int(hv) if rpeev else int(Tools.half_up(hv * 255.0)))
						di1.set("startTime", ht)
						arr.append(di1)
						continue
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1) if rpeev else int(Tools.half_up(k["value"].get(1) * 255)))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0) if rpeev else int(Tools.half_up(k["value"].get(0) * 255)))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("alphaEvents", arr)
				arr = Array()
				for k in j["x"]:
					if k["ease"] == Tween.EaseType.EASE_OUT_IN:
						var ht := Tools.beat_add(k["beat"].get(0), Tools.beat_divide(Tools.beat_subtract(k["beat"].get(1), k["beat"].get(0)), [2, 0, 1]))
						var hv: float = k["value"].get(0) + (k["value"].get(1) - k["value"].get(0)) / 2.0
						var di1 := Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						var easing1: int = 1
						for l in RPE_EASINGS_MAPPING.size():
							if [k["transition"],Tween.EaseType.EASE_IN_OUT] == RPE_EASINGS_MAPPING.get(l):
								easing1 = l - 2
						di1.set("easingType", easing1)
						di1.set("end", hv if rpeev else (hv * 675.0))
						di1.set("endTime", ht)
						di1.set("linkgroup", 0)
						di1.set("start", k["value"].get(0) if rpeev else (k["value"].get(0) * 675.0))
						di1.set("startTime", k["beat"].get(0))
						arr.append(di1)
						di1 = Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						if easing1 > 1:
							easing1 += 1
						di1.set("easingType", easing1)
						di1.set("end", k["value"].get(1) if rpeev else (k["value"].get(1) * 675.0))
						di1.set("endTime", k["beat"].get(1))
						di1.set("linkgroup", 0)
						di1.set("start", hv if rpeev else (hv * 675.0))
						di1.set("startTime", ht)
						arr.append(di1)
						continue
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1) * (1.0 if rpeev else 675.0))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0) * (1.0 if rpeev else 675.0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("moveXEvents", arr)
				arr = Array()
				for k in j["y"]:
					if k["ease"] == Tween.EaseType.EASE_OUT_IN:
						var ht := Tools.beat_add(k["beat"].get(0), Tools.beat_divide(Tools.beat_subtract(k["beat"].get(1), k["beat"].get(0)), [2, 0, 1]))
						var hv: float = k["value"].get(0) + (k["value"].get(1) - k["value"].get(0)) / 2.0
						var di1 := Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						var easing1: int = 1
						for l in RPE_EASINGS_MAPPING.size():
							if [k["transition"],Tween.EaseType.EASE_IN_OUT] == RPE_EASINGS_MAPPING.get(l):
								easing1 = l - 2
						di1.set("easingType", easing1)
						di1.set("end", hv if rpeev else (hv * -450.0))
						di1.set("endTime", ht)
						di1.set("linkgroup", 0)
						di1.set("start", k["value"].get(0) if rpeev else (k["value"].get(0) * -450.0))
						di1.set("startTime", k["beat"].get(0))
						arr.append(di1)
						di1 = Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						if easing1 > 1:
							easing1 += 1
						di1.set("easingType", easing1)
						di1.set("end", k["value"].get(1) if rpeev else (k["value"].get(1) * -450.0))
						di1.set("endTime", k["beat"].get(1))
						di1.set("linkgroup", 0)
						di1.set("start", hv if rpeev else (hv * -450.0))
						di1.set("startTime", ht)
						arr.append(di1)
						continue
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1) * (1.0 if rpeev else -450.0))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0) * (1.0 if rpeev else -450.0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("moveYEvents", arr)
				arr = Array()
				for k in j["rotate"]:
					if k["ease"] == Tween.EaseType.EASE_OUT_IN:
						var ht := Tools.beat_add(k["beat"].get(0), Tools.beat_divide(Tools.beat_subtract(k["beat"].get(1), k["beat"].get(0)), [2, 0, 1]))
						var hv: float = k["value"].get(0) + (k["value"].get(1) - k["value"].get(0)) / 2.0
						var di1 := Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						var easing1: int = 1
						for l in RPE_EASINGS_MAPPING.size():
							if [k["transition"],Tween.EaseType.EASE_IN_OUT] == RPE_EASINGS_MAPPING.get(l):
								easing1 = l - 2
						di1.set("easingType", easing1)
						di1.set("end", hv)
						di1.set("endTime", ht)
						di1.set("linkgroup", 0)
						di1.set("start", k["value"].get(0))
						di1.set("startTime", k["beat"].get(0))
						arr.append(di1)
						di1 = Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						if easing1 > 1:
							easing1 += 1
						di1.set("easingType", easing1)
						di1.set("end", k["value"].get(1))
						di1.set("endTime", k["beat"].get(1))
						di1.set("linkgroup", 0)
						di1.set("start", hv)
						di1.set("startTime", ht)
						arr.append(di1)
						continue
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("rotateEvents", arr)
				arr = Array()
				for k in j["speed"]:
					if k["ease"] == Tween.EaseType.EASE_OUT_IN:
						var ht := Tools.beat_add(k["beat"].get(0), Tools.beat_divide(Tools.beat_subtract(k["beat"].get(1), k["beat"].get(0)), [2, 0, 1]))
						var hv: float = k["value"].get(0) + (k["value"].get(1) - k["value"].get(0)) / 2.0
						var di1 := Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						var easing1: int = 1
						for l in RPE_EASINGS_MAPPING.size():
							if [k["transition"],Tween.EaseType.EASE_IN_OUT] == RPE_EASINGS_MAPPING.get(l):
								easing1 = l - 2
						di1.set("easingType", easing1)
						di1.set("end", hv if rpeev else (hv * 900.0 / 120.0))
						di1.set("endTime", ht)
						di1.set("linkgroup", 0)
						di1.set("start", k["value"].get(0) if rpeev else (k["value"].get(0) * 900.0 / 120.0))
						di1.set("startTime", k["beat"].get(0))
						arr.append(di1)
						di1 = Dictionary()
						di1.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
						di1.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
						di1.set("easingLeft", 0.0)
						di1.set("easingRight", 1.0)
						if easing1 > 1:
							easing1 += 1
						di1.set("easingType", easing1)
						di1.set("end", k["value"].get(1) if rpeev else (k["value"].get(1) * 900.0 / 120.0))
						di1.set("endTime", k["beat"].get(1))
						di1.set("linkgroup", 0)
						di1.set("start", hv if rpeev else (hv * 900.0 / 120.0))
						di1.set("startTime", ht)
						arr.append(di1)
						continue
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1) * (1.0 if rpeev else 900.0 / 120.0))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0) * (1.0 if rpeev else 900.0 / 120.0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("speedEvents", arr)
				if not dic.is_empty():
					arra.append(dic)
			line.set("eventLayers", arra)
			if i.has("extra"):
				var j: Dictionary = i["extra"]
				var dic := Dictionary()
				var arr := Array()
				for k in j["color"]:
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					var color := Color.from_string(k["value"].get(1), Color.WHITE)
					di.set("end", [color.r8,color.g8,color.b8])
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					color = Color.from_string(k["value"].get(0), Color.WHITE)
					di.set("start", [color.r8,color.g8,color.b8])
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("colorEvents", arr)
				arr = Array()
				for k in j["incline"]:
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("inclineEvents", arr)
				arr = Array()
				for k in j["x"]:
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("scaleXEvents", arr)
				arr = Array()
				for k in j["y"]:
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("scaleYEvents", arr)
				arr = Array()
				for k in j["text"]:
					var di := Dictionary()
					di.set("bezier", (1)if((k.has("bezier"))and(k["bezier"]))else(0))
					di.set("bezierPoints", k["bezier"]if((k.has("bezier"))and(k["bezier"]))else[0.0,0.0,0.0,0.0])
					di.set("easingLeft", 0.0)
					di.set("easingRight", 1.0)
					var easing: int = 1
					for l in RPE_EASINGS_MAPPING.size():
						if [k["transition"],k["ease"]] == RPE_EASINGS_MAPPING.get(l):
							easing = l + 1
					di.set("easingType", easing)
					di.set("end", k["value"].get(1))
					di.set("endTime", k["beat"].get(1))
					di.set("linkgroup", 0)
					di.set("start", k["value"].get(0))
					di.set("startTime", k["beat"].get(0))
					arr.append(di)
				if not arr.is_empty():
					dic.set("textEvents", arr)
				if not dic.is_empty():
					line.set("extended", dic)
			line.set("father", i["father"])
			line.set("isCover", int(i["cover"]))
			arra = Array()
			for j in i["note"]:
				var _type = j["type"]
				if _type == 1 and j["beat"].size() == 2:
					_type = 2
				elif _type > 1:
					_type += 1
				arra.append({"above":int(j["above"]),"alpha":int(Tools.half_up(j["alpha"]*((1.0)if(rpeev)else(255.0)))),"endTime":j["beat"]if(j["beat"].size()==3)else(j["beat"].get(1)),"isFake":int(j["fake"]),"positionX":j["x"]*((1.0)if(rpeev)else(675.0)),"size":j["wide"],"speed":j["speed"],"startTime":j["beat"]if(j["beat"].size()==3)else(j["beat"].get(0)),"type":_type,"visibleTime":j["visible"],"yOffset":j["y"]*((1.0)if(rpeev)else(450.0))})
			if not arra.is_empty():
				line.set("notes", arra)
			line.set("posControl", [{"easing":1,"pos":1.0,"x":0.0},{"easing":1,"pos":1.0,"x":9999999.0}])
			line.set("sizeControl", [{"easing":1,"size":1.0,"x":0.0},{"easing":1,"size":1.0,"x":9999999.0}])
			line.set("skewControl", [{"easing":1,"skew":0.0,"x":0.0},{"easing":1,"skew":0.0,"x":9999999.0}])
			line.set("yControl", [{"easing":1,"x":0.0,"y":1.0},{"easing":1,"x":9999999.0,"y":1.0}])
			line.set("zOrder", i["z"])
			array.append(line)
		result.set("judgeLineList", array)
		result.set("multiLineString", "")
		result.set("multiScale", 1.0)
	else:
		result = loaded
	var fa := FileAccess.open(OS.get_cache_dir() + SEPARATOR + path + ".json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(result))
	fa.close()
	fa = FileAccess.open(OS.get_cache_dir() + SEPARATOR + ("info.txt" if rpe else "info.json"), FileAccess.WRITE)
	fa.store_string("#\nComposer: " + info["artist"] + "\nChart: " + info["path"] + ".json\nCharter: " + info["author"] + "\nPath: " + info["path"] + "\nPicture: " + info["illustration"] + "\nIllustrator: " + info["illustrator"] + "\nLevel: " + info["level"] + "\nName: " + info["chart"] + "\nSong: " + info["music"] + "\nOffset: " + String.num_int64(info["offset"]) + "\n" if rpe else JSON.stringify(info))
	fa.close()
	for i in DirAccess.open(DIR + SEPARATOR + path).get_files():
		if i.to_lower() == path.to_lower() + ".json" or i.to_lower() == "info.json":
			continue
		DirAccess.copy_absolute(DIR + SEPARATOR + path + SEPARATOR + i, OS.get_cache_dir() + SEPARATOR + i)
	var zp := ZIPPacker.new()
	zp.open(p)
	var da := DirAccess.open(OS.get_cache_dir())
	for i in da.get_files():
		zp.start_file(i)
		fa = FileAccess.open(OS.get_cache_dir() + SEPARATOR + i, FileAccess.READ)
		zp.write_file(fa.get_buffer(fa.get_length()))
		zp.close_file()
		fa.close()
	zp.close()
	for i in da.get_files():
		da.remove(i)
	if share:
		ShareFile.share(p)
	return Error.OK
## Load music data into [code]stream[/code]. Only used when loading chart.
func load_music() -> void:
	var music: String = DIR + path + "/" + info["music"]
	match info["music"].get_extension():
		"mp3":
			stream = AudioStreamMP3.load_from_file(music)
		"ogg":
			stream = AudioStreamOggVorbis.load_from_file(music)
		"wav":
			stream = AudioStreamWAV.load_from_file(music)
	if not stream:
		Log.w("Unsupportd audio format! Falling back...")
		stream = AudioStreamMP3.load_from_file(music)
		if not stream:
			stream = AudioStreamOggVorbis.load_from_file(music)
			if not stream:
				stream = AudioStreamWAV.load_from_file(music)
	if not stream:
		Log.e("Audio loaded failed!")
## Read the chart file then move the data into [code]loaded[/code] dictionary. It also format the chart file.
func load_chart() -> void:
	Log.i("Loading chart...")
	if not info.has("format"):
		info.set("format", "phiator")
	var fn: bool = info["format"] != settings["data"]
	var rpe: bool = settings["data"] == "rpe"
	path = info["path"]
	if info.has("version"):
		info.set("level", info["version"])
		info.erase("version")
	load_music()
	var fa = FileAccess.open(DIR + SEPARATOR + path + SEPARATOR + path + ".json", FileAccess.READ)
	if not fa:
		Log.e("Chart open failed... Error code: " + str(FileAccess.get_open_error()))
		Log.w("Stopping load process...")
		return
	loaded = JSON.parse_string(fa.get_as_text())
	fa.close()
	for i in loaded["bpm"]:
		for j in i["beat"].size():
			i["beat"].set(j, int(i["beat"].get(j)))
	for i in loaded["line"]:
		for j in i["event"]:
			for k in j["alpha"]:
				for l in k["beat"]:
					for m in l.size():
						l.set(m, int(l.get(m)))
				k.set("ease", int(k["ease"]))
				k.set("transition", int(k["transition"]))
				if fn:
					k["value"].set(0, int(Tools.half_up(k["value"].get(0) * 255.0)) if rpe else (k["value"].get(0) / 255.0))
					k["value"].set(1, int(Tools.half_up(k["value"].get(1) * 255.0)) if rpe else (k["value"].get(1) / 255.0))
			for k in j["rotate"]:
				for l in k["beat"]:
					for m in l.size():
						l.set(m, int(l.get(m)))
				k.set("ease", int(k["ease"]))
				k.set("transition", int(k["transition"]))
			for k in j["speed"]:
				for l in k["beat"]:
					for m in l.size():
						l.set(m, int(l.get(m)))
				k.set("ease", 0)
				k.set("transition", 0)
				if fn:
					k["value"].set(0, int(Tools.half_up(k["value"].get(0) * 900.0 / 120.0)) if rpe else (k["value"].get(0) * 120.0 / 900.0))
					k["value"].set(1, int(Tools.half_up(k["value"].get(1) * 900.0 / 120.0)) if rpe else (k["value"].get(1) * 120.0 / 900.0))
			for k in j["x"]:
				for l in k["beat"]:
					for m in l.size():
						l.set(m, int(l.get(m)))
				k.set("ease", int(k["ease"]))
				k.set("transition", int(k["transition"]))
				if fn:
					k["value"].set(0, int(Tools.half_up(k["value"].get(0) * 675.0)) if rpe else (k["value"].get(0) / 675.0))
					k["value"].set(1, int(Tools.half_up(k["value"].get(1) * 675.0)) if rpe else (k["value"].get(1) / 675.0))
			for k in j["y"]:
				for l in k["beat"]:
					for m in l.size():
						l.set(m, int(l.get(m)))
				k.set("ease", int(k["ease"]))
				k.set("transition", int(k["transition"]))
				if fn:
					k["value"].set(0, int(Tools.half_up(k["value"].get(0) * -450.0)) if rpe else (k["value"].get(0) / -450.0))
					k["value"].set(1, int(Tools.half_up(k["value"].get(1) * -450.0)) if rpe else (k["value"].get(1) / -450.0))
		if i.has("extra"):
			var extra: Dictionary = i["extra"]
			for j in extra["color"]:
				for k in j["beat"]:
					for l in k.size():
						k.set(l, int(k.get(l)))
				j.set("ease", int(j["ease"]))
				j.set("transition", int(j["transition"]))
			for j in extra["incline"]:
				for k in j["beat"]:
					for l in k.size():
						k.set(l, int(k.get(l)))
				j.set("ease", int(j["ease"]))
				j.set("transition", int(j["transition"]))
			for j in extra["text"]:
				for k in j["beat"]:
					for l in k.size():
						k.set(l, int(k.get(l)))
				j.set("ease", int(j["ease"]))
				j.set("transition", int(j["transition"]))
			for j in extra["x"]:
				for k in j["beat"]:
					for l in k.size():
						k.set(l, int(k.get(l)))
				j.set("ease", int(j["ease"]))
				j.set("transition", int(j["transition"]))
			for j in extra["y"]:
				for k in j["beat"]:
					for l in k.size():
						k.set(l, int(k.get(l)))
				j.set("ease", int(j["ease"]))
				j.set("transition", int(j["transition"]))
		i.set("father", int(i["father"]) if i.has("father") else -1)
		for j in i["note"]:
			if j["beat"].size() == 2:
				for k in j["beat"]:
					for l in k.size():
						k.set(l, int(k.get(l)))
			else:
				for k in j["beat"].size():
					j["beat"].set(k, int(j["beat"].get(k)))
			j.set("type", int(j["type"]))
			if not j.has("visible"):
				j.set("visible", 9999999.0)
			if fn:
				j.set("alpha", int(Tools.half_up(j["alpha"] * 255.0)) if rpe else (j["alpha"] / 255.0))
				j.set("x", (j["x"] * 675.0) if rpe else (j["x"] / 675.0))
				j.set("y", (j["y"] * 900.0) if rpe else (j["y"] / 900.0))
		i.set("ui", int(i["ui"] if i.has("ui") else 0))
		i.set("z", int(i["z"]) if i.has("z") else 0)
	sort_chart()
	info["format"] = settings["data"]
## Sort the items in [code]loaded[/code] dictionary. It will sort all notes and events in chronological order.
func sort_chart() -> bool:
	var result: bool = false
	for i in loaded["line"]:
		for j in i["event"]:
			if j.has("alpha") and j["alpha"].size() > 0:
				j["alpha"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = j["alpha"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					j["alpha"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[0.0,0.0]})
					result = true
			if j.has("rotate") and j["rotate"].size() > 0:
				j["rotate"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = j["rotate"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					j["rotate"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[0.0,0.0]})
					result = true
			if j.has("speed") and j["speed"].size() > 0:
				j["speed"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = j["speed"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					j["speed"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[0.0,0.0]})
					result = true
			if j.has("x") and j["x"].size() > 0:
				j["x"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = j["x"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					j["x"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[0.0,0.0]})
					result = true
			if j.has("y") and j["y"].size() > 0:
				j["y"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = j["y"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					j["y"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[0.0,0.0]})
					result = true
		if i.has("extra"):
			var e: Dictionary = i["extra"]
			if e.has("color") and e["color"].size() > 0:
				e["color"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = e["color"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					e["color"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":["ffffff","ffffff"]})
					result = true
			if e.has("incline") and e["incline"].size() > 0:
				e["incline"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = e["incline"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					e["incline"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[0.0,0.0]})
					result = true
			if e.has("text") and e["text"].size() > 0:
				e["text"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = e["text"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					e["text"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":["",""]})
					result = true
			if e.has("x") and e["x"].size() > 0:
				e["x"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = e["x"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					e["x"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[1.0,1.0]})
					result = true
			if e.has("y") and e["y"].size() > 0:
				e["y"].sort_custom(func(a: Dictionary, b: Dictionary): return Tools.compare_beat(a["beat"].get(0), b["beat"].get(0)) < 0)
				var first: Dictionary = e["y"].get(0)
				if Tools.compare_beat(first["beat"].get(0), [0,0,1]) > 0:
					e["y"].push_front({"beat":[[0,0,1],Tools.min_beat(first["beat"].get(0),[1,0,1])],"ease":0,"transition":0,"value":[1.0,1.0]})
					result = true
		if i.has("note") and i["note"].size() > 0:
			i["note"].sort_custom(func(a: Dictionary, b: Dictionary):
				if Tools.compare_beat(a["beat"].get(0) if a["beat"].size() == 2 else a["beat"], b["beat"].get(0) if b["beat"].size() == 2 else b["beat"]) == 0:
					if a["x"] == b["x"]:
						return a["type"] < b["type"]
					return a["x"] < b["x"]
				return Tools.compare_beat(a["beat"].get(0) if a["beat"].size() == 2 else a["beat"], b["beat"].get(0) if b["beat"].size() == 2 else b["beat"]) < 0
			)
	return result
## Transform bpm list into high efficiency data.
func get_bpm() -> void:
	Log.i("Getting BPM list...")
	bpm.clear()
	var list: Array = loaded["bpm"]
	var time: float = 0.0
	for i in list.size():
		if i == 0:
			bpm.append({"bpm":list.get(i)["bpm"],"time":0})
			continue
		var last: Array = list.get(i - 1)["beat"]
		var this: Array = list.get(i)["beat"]
		time += 60.0 / list.get(i - 1)["bpm"] * (Tools.beat_to_float(this) - Tools.beat_to_float(last))
		bpm.append({"bpm":list.get(i)["bpm"],"time":time})
## Load the properties file.
func get_properties() -> void:
	Log.i("Getting properties...")
	if not FileAccess.file_exists(DIR + "editor.json"):
		Log.w("Properties file doesn't exist. Creating...")
		var faw := FileAccess.open(DIR + "editor.json", FileAccess.WRITE)
		faw.store_string("{}")
		faw.close()
	var far := FileAccess.open(DIR + "editor.json", FileAccess.READ)
	properties = JSON.parse_string(far.get_as_text())
	far.close()
	for i in Global.default_properties:
		if not properties.has(i.get(0)):
			Log.w("Property " + i.get(0) + " doesn't exist. Setting to the default value: " + str(i.get(1)))
			properties.set(i.get(0), i.get(1))
## Save the properties.[br]
## [code]args[/code]: The value of each property item. For the order, please check [code]default_properties[/code] array.
func save_properties(...args) -> void:
	Log.i("Saving properties...")
	for i in default_properties.size():
		properties.set(default_properties.get(i).get(0), args.get(i))
	var fa := FileAccess.open(DIR + "editor.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(properties))
	fa.close()
## Save the chart.
func save_chart() -> void:
	Log.i("Saving chart...")
	var fa := FileAccess.open(DIR + path + "/" + "info.json", FileAccess.WRITE)
	if not fa:
		Global.make_notification(tr("save_failed"))
		Log.e("info.json open failed... Error code: " + str(FileAccess.get_open_error()))
		Log.w("Stopping saving process...")
		return
	fa.store_string(JSON.stringify(info))
	fa.close()
	fa = FileAccess.open(DIR + path + "/" + path + ".json", FileAccess.WRITE)
	if not fa:
		Global.make_notification(tr("save_failed"))
		Log.e("Chart open failed... Error code: " + str(FileAccess.get_open_error()))
		Log.w("Stopping saving process...")
		return
	fa.store_string(JSON.stringify(loaded))
	fa.close()
