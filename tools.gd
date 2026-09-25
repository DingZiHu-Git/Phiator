## Some tool functions.
extends Node

## Add 2 beats.
func beat_add(b1: Array, b2: Array) -> Array:
	var num: int = b1.get(0) + b2.get(0)
	var up: int = b1.get(1) * b2.get(2) + b2.get(1) * b1.get(2)
	var down: int = b1.get(2) * b2.get(2)
	while up >= down:
		num += 1
		up -= down
	var factor := gcd(down, up)
	@warning_ignore("integer_division")
	return [num, up / factor, down / factor]
## Divide 2 beats. [code]b1[/code] will be divided by [code]b2[/code].
func beat_divide(b1: Array, b2: Array) -> Array:
	var num: int = 0
	var up: int = (b1.get(0) * b1.get(2) + b1.get(1)) * b2.get(2)
	var down: int = (b2.get(0) * b2.get(2) + b2.get(1)) * b1.get(2)
	while up >= down:
		num += 1
		up -= down
	var factor := gcd(down, up)
	@warning_ignore("integer_division")
	return [num, up / factor, down / factor]
## Multiply 2 beats.
func beat_multiply(b1: Array, b2: Array) -> Array:
	var num: int = b1.get(0) * b2.get(0)
	var up: int = b1.get(1) * b2.get(1)
	var down: int = b1.get(2) * b2.get(2)
	var factor := gcd(down, up)
	@warning_ignore("integer_division")
	return [num, up / factor, down / factor]
## Subtract 2 beats. [code]b1[/code] will be subtracted by [code]b2[/code].
func beat_subtract(b1: Array, b2: Array) -> Array:
	var num: int = b1.get(0) - b2.get(0)
	var up: int = b1.get(1) * b2.get(2) - b2.get(1) * b1.get(2)
	var down: int = b1.get(2) * b2.get(2)
	while up < 0:
		num -= 1
		up -= down
	var factor := gcd(down, up)
	@warning_ignore("integer_division")
	return [num, up / factor, down / factor]
## Convert beat the float.
func beat_to_float(b: Array) -> float:
	return b.get(0) + b.get(1) / float(b.get(2))
## Convert beat to sec.
func beat_to_time(b: Array) -> float:
	return float_to_time(beat_to_float(b))
## Clear all files in the folder. It will not remove the folder itself.
func clear_folder(path: String, include_hidden: bool = true) -> void:
	var da: DirAccess = DirAccess.open(path)
	if not da:
		DirAccess.remove_absolute(path)
		return
	da.include_hidden = include_hidden
	da.list_dir_begin()
	var fn: String = da.get_next()
	while fn != "":
		if da.current_is_dir():
			da.change_dir(fn)
			clear_folder(da.get_current_dir())
			da.change_dir("..")
		da.remove(fn)
		fn = da.get_next()
	da.list_dir_end()
## Compare 2 beats.[br]
## It returns a int, which indicates the relation between the 2 beats. If [code]b1[/code] is smaller than [code]b2[/code], then it returns -1; If [code]b1[/code] is bigger than [code]b2[/code], then it returns 1; If they are the same, then it returns 0.
func compare_beat(b1: Array, b2: Array) -> int:
	if b1.get(0) > b2.get(0): return 1
	elif b1.get(0) < b2.get(0): return -1
	else:
		var n1: int = b1.get(1) * b2.get(2)
		var n2: int = b2.get(1) * b1.get(2)
		if n1 > n2: return 1
		elif n1 < n2: return -1
		return 0
## Copy the file from [code]from[/code] to [code]to[/code].
func copy_file(from: String, to: String) -> void:
	var far := FileAccess.open(from, FileAccess.READ)
	var faw := FileAccess.open(to, FileAccess.WRITE)
	faw.store_buffer(far.get_buffer(far.get_length()))
	faw.close()
	far.close()
## Convert float to beat.[br]
## [code]f[/code]: The float need to be converted.[br]
## [code]md[/code]: How large the denominator can reach.[br]
## [code]t[/code]: Tolerance. Smaller value make the result more accurate, but it can also return wrong value in some extreme conditions.
func float_to_beat(f: float, md: int, t: float = 1e-6) -> Array:
	var num: int = int(f)
	f -= num
	var up: int = 0
	var down: int = 1
	for i in md + 1:
		for j in i:
			var v: float = abs(j / float(i) - f)
			if v < t:
				var d: int = gcd(j, i)
				@warning_ignore("integer_division")
				return [num, j / d, i / d]
			elif v < abs(up / float(down) - f):
				up = j
				down = i
	var divisor: int = gcd(up, down)
	@warning_ignore("integer_division")
	return [num, up / divisor, down / divisor]
## Convert float to sec. Usually be invoked with [code]beat_to_float[/code] before.[br]
## [code]f[/code]: The float need to be converted.
func float_to_time(f: float) -> float:
	var result: float = 0
	var bpm: Array = Global.loaded["bpm"]
	for i in bpm.size():
		var current: Dictionary = bpm.get(i)
		var next = null if i == bpm.size() - 1 else bpm.get(i + 1)
		if next == null or beat_to_float(next["beat"]) > f:
			result += (f - beat_to_float(current["beat"])) / current["bpm"] * 60
			break
		result += (beat_to_float(next["beat"]) - beat_to_float(current["beat"])) / current["bpm"] * 60
	return result
## Find the greatest common divisor of [code]a[/code] and [code]b[/code].
func gcd(a: int, b: int) -> int:
	return a if b == 0 else gcd(b, a % b)
## Get the main activity on Android. Do not invoke on other os.
func get_android_activity() -> Object:
	return Engine.get_singleton(&"AndroidRuntime").getActivity()
## Get the filename of the file in the given path.[br]
## [code]path[/code]: File path. It's a content uri returned by SAF on Android.
func get_filename(path: String) -> String:
	if OS.get_name() == "Android" and not (path.begins_with("res://") or path.begins_with("user://")):
		var df: Object = JavaClassWrapper.wrap("androidx.documentfile.provider.DocumentFile").fromSingleUri(get_android_activity(), JavaClassWrapper.wrap("android.net.Uri").parse(path))
		return df.getName() if df else "null"
	else:
		return path.get_file()
## (Well I wonder what will happen if I don't write anything for this function)
func half_up(f: float) -> float:
	var result: float = float(int(f))
	var num: String = String.num(f)
	return result + (1 if int(num.substr(num.find(".") + 1, 1)) > 4 else 0)
## Find the maximum beat in the given array [code]b[/code].
func max_beat(...b: Array) -> Array:
	var result: Array = [-2147483648, 0, 1]
	for a in b:
		if compare_beat(a, result) > 0:
			result = a
	return result
## Find the minimum beat in the given array [code]b[/code].
func min_beat(...b: Array) -> Array:
	var result: Array = [2147483647, 0, 1]
	for a in b:
		if compare_beat(a, result) < 0:
			result = a
	return result
## Parse the music file. If the file has no extension or its extension is not match its true format, then the function will add/replace its real extension after the filename.[br]
## [code]p[/code]: Music file path. It's a content uri returned by SAF on Android.[br]
## [code]f[/code]: The format of the music. If it's empty, then the function will parse the music automatically to find the real format of the file.[br]
## Returns the full filename of the music file. It contains the true extension of the file.
func parse_music(p: String, f: String = "") -> String:
	if f == "":
		if AudioStreamMP3.load_from_file(p):
			f = "mp3"
		elif AudioStreamOggVorbis.load_from_file(p):
			f = "ogg"
		elif AudioStreamWAV.load_from_file(p):
			f = "wav"
	var fn: String = Tools.get_filename(p)
	if fn.get_extension() == "" or fn.get_extension() not in [ "mp3", "ogg", "wav" ]:
		Log.w("Detected the filename of the audio has no valid extension. Filling...")
		fn += "." + f
	elif fn.get_extension() != f:
		Log.w("Detected the extension of the audio doesn't match the format. Replacing...")
		fn = fn.substr(0, fn.rfind(".") + 1) + f
	return fn
