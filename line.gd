extends TextureRect

const start := Vector2(0.0, 0.0)
const end := Vector2(1.0, 1.0)
var cover: bool = true
var event: Array[Array] = []
var extra: Array[Array] = [[],[],[],[],[]]
var father: int = -1
var text: String = ""
var speed: float = 0
var parent: Control
var progress: ProgressBar
var values: PackedFloat64Array = PackedFloat64Array()
var ex: Array = Array()
func _ready() -> void:
	parent = $".."
	progress = $"../Progress"
	values.resize(5)
	ex.resize(5)
func _process(_delta: float) -> void:
	values.fill(0.0)
	for i in event:
		for j in i.size():
			var arr: Array = i.get(j)
			if j == 2:
				for k in arr.size():
					var l: Dictionary = arr[k]
					var last: Dictionary
					if k > 0:
						last = arr[k - 1]
					var time: Array = l["time"]
					var value: float = l["value"]
					var delta: float = l["delta"]
					if time.get(1) < progress.value:
						values.set(j, values.get(j) + (time.get(1) - time.get(0)) * (value * 2.0 + delta) / 2.0)
						if k > 0:
							values.set(j, values.get(j) + (time.get(0) - last["time"].get(1)) * (last["value"] + last["delta"]))
						if k == arr.size() - 1:
							values.set(j, values.get(j) + (progress.value - time.get(1)) * (value + delta))
					elif time.get(0) > progress.value:
						if k > 0:
							values.set(j, values.get(j) + (progress.value - last["time"].get(1)) * (last["value"] + last["delta"]))
						break
					else:
						values.set(j, values.get(j) + (progress.value - time.get(0)) * (value * 2.0 + delta * (progress.value - time.get(0)) / (time.get(1) - time.get(0))) / 2.0)
						if k > 0:
							values.set(j, values.get(j) + (time.get(0) - last["time"].get(1)) * (last["value"] + last["delta"]))
						break
			else:
				if arr.size() == 0:
					pass
				else:
					var left: int = 0
					var right: int = arr.size() - 1
					var found_index: int = -1
					while left <= right:
						var mid: int = int((left + right) / 2.0)
						var l: Dictionary = arr[mid]
						if l["time"].get(0) <= progress.value and l["time"].get(1) >= progress.value:
							found_index = mid
							break
						elif l["time"].get(0) > progress.value:
							right = mid - 1
						else:
							left = mid + 1
					if found_index != -1:
						var l: Dictionary = arr[found_index]
						var t: Array = l["time"]
						values.set(j, values.get(j) + ((l["value"] + l["delta"] * start.bezier_interpolate(Vector2(l["bezier"].get(0), l["bezier"].get(1)), Vector2(l["bezier"].get(2), l["bezier"].get(3)), end, (progress.value - t.get(0)) / (t.get(1) - t.get(0))).y) if l["bezier"] else Tween.interpolate_value(l["value"], l["delta"], progress.value - t.get(0), t.get(1) - t.get(0), l["transition"], l["ease"])))
					else:
						if left == 0:
							var first: Dictionary = arr[0]
							values.set(j, values.get(j) + first["value"])
						elif left >= arr.size():
							var last_elem: Dictionary = arr[arr.size() - 1]
							values.set(j, values.get(j) + last_elem["value"] + last_elem["delta"])
						else:
							var l: Dictionary = arr[left - 1]
							values.set(j, values.get(j) + l["value"] + l["delta"])
	ex.set(0, [0, 0, 0])
	ex.set(1, 0.0)
	ex.set(2, "")
	ex.set(3, 0.0)
	ex.set(4, 0.0)
	for j in extra.size():
		var arr: Array = extra.get(j)
		if arr.size() == 0:
			if j == 0:
				ex.set(j, [255, 255, 255])
			elif j == 3 or j == 4:
				ex.set(j, 1.0)
		else:
			var left: int = 0
			var right: int = arr.size() - 1
			var found_index: int = -1
			while left <= right:
				var mid: int = int((left + right) / 2.0)
				var l: Dictionary = arr[mid]
				if l["time"].get(0) <= progress.value and l["time"].get(1) >= progress.value:
					found_index = mid
					break
				elif l["time"].get(0) > progress.value:
					right = mid - 1
				else:
					left = mid + 1
			if found_index != -1:
				var l: Dictionary = arr[found_index]
				var t: Array = l["time"]
				if j == 0:
					if l["bezier"]:
						pass
					else:
						ex.set(j, [ex.get(j).get(0) + Tween.interpolate_value(l["value"].get(0), l["delta"].get(0), progress.value - l["time"].get(0), l["time"].get(1) - l["time"].get(0), l["transition"], l["ease"]), ex.get(j).get(1) + Tween.interpolate_value(l["value"].get(1), l["delta"].get(1), progress.value - l["time"].get(0), l["time"].get(1) - l["time"].get(0), l["transition"], l["ease"]), ex.get(j).get(2) + Tween.interpolate_value(l["value"].get(2), l["delta"].get(2), progress.value - l["time"].get(0), l["time"].get(1) - l["time"].get(0), l["transition"], l["ease"])])
				else:
					ex.set(j, ex.get(j) + (l["value"] + l["delta"] * Vector2(0.0, 0.0).bezier_interpolate(Vector2(l["bezier"].get(0), l["bezier"].get(1)), Vector2(l["bezier"].get(2), l["bezier"].get(3)), Vector2(1.0, 1.0), (progress.value - t.get(0)) / (t.get(1) - t.get(0))).y) if l["bezier"] else Tween.interpolate_value(l["value"], l["delta"], progress.value - l["time"].get(0), l["time"].get(1) - l["time"].get(0), l["transition"], l["ease"]) if j != 2 else "")
			else:
				if left == 0:
					var first: Dictionary = arr[0]
					ex.set(j, ([ex.get(j).get(0) + first["value"].get(0), ex.get(j).get(1) + first["value"].get(1), ex.get(j).get(2) + first["value"].get(2)]) if j == 0 else (ex.get(j) + first["value"]))
				elif left >= arr.size():
					var last_elem: Dictionary = arr[arr.size() - 1]
					if j == 0:
						ex.set(j, [ex.get(j).get(0) + last_elem["value"].get(0) + last_elem["delta"].get(0), ex.get(j).get(1) + last_elem["value"].get(1) + last_elem["delta"].get(1), ex.get(j).get(2) + last_elem["value"].get(2) + last_elem["delta"].get(2)])
					else:
						ex.set(j, ex.get(j) + last_elem["value"] + last_elem["delta"] if j != 2 else "")
				else:
					var l: Dictionary = arr[left - 1]
					if j == 0:
						ex.set(j, [ex.get(j).get(0) + l["value"].get(0) + l["delta"].get(0), ex.get(j).get(1) + l["value"].get(1) + l["delta"].get(1), ex.get(j).get(2) + l["value"].get(2) + l["delta"].get(2)])
					else:
						ex.set(j, ex.get(j) + l["value"] + l["delta"] if j != 2 else "")
	self_modulate = Color.from_rgba8(ex.get(0).get(0), ex.get(0).get(1), ex.get(0).get(2), max(0, int(values.get(0) * 255)))
	rotation_degrees = values.get(1)
	speed = values.get(2)
	size = Vector2(((parent.size.y * 5.76) if text.is_empty() else float(texture.get_width()) / 1366.0 * parent.size.x) * ex.get(3), ((parent.size.y * 0.0075) if text.is_empty() else float(texture.get_height()) / 768.0 * parent.size.y) * ex.get(4))
	if father > -1:
		var fl: TextureRect = parent.get_child(father)
		set_deferred(&"position", Vector2((fl.values.get(3) + 1.0) * parent.size.x / 2.0, (fl.values.get(4) + 1.0) * parent.size.y / 2.0) + Vector2(values.get(3) * parent.size.x / 2.0, values.get(4) * parent.size.y / 2.0).rotated(fl.rotation))
	else:
		position = Vector2((values.get(3) + 1.0) * parent.size.x / 2.0, (values.get(4) + 1.0) * parent.size.y / 2.0)
