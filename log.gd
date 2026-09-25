## Custom logger class.
class_name Log extends Logger

## Current log file name.
static var _cl: String
## Log path.
static var _lp: String
static func _static_init() -> void:
	_cl = "log_%s.log" % String.num_uint64(int(Time.get_unix_time_from_system() * 1000))
	_lp = (("/storage/emulated/0/Android/data/org.godotengine.editor.v4/files/" + ProjectSettings.get_setting("application/config/name")) if OS.has_feature("editor") else Engine.get_singleton(&"AndroidRuntime").getActivity().getExternalFilesDir("").getAbsolutePath()) + "/logs/" if OS.get_name() == "Android" else "user://logs/"
	DirAccess.make_dir_absolute(_lp)
	var fa: FileAccess = FileAccess.open(_lp + _cl, FileAccess.ModeFlags.WRITE)
	if fa:
		fa.close()
	clear_logs(true)
	OS.add_logger(Log.new())
## Universal log function.[br]
## [code]t[/code]: Time string.[br]
## [code]m[/code]: Log message.
static func _log(t: String, m: String) -> void:
	var fa: FileAccess = FileAccess.open(_lp + _cl, FileAccess.ModeFlags.READ_WRITE)
	if fa:
		fa.seek_end()
		fa.store_string("%s\t|\t%s\t|\t%s\n" % [Time.get_datetime_string_from_system(false, true), t, m])
		fa.close()
## Clear all logs in log path.[br]
## [code]keep_latest[/code]: Whether keep the latest log or not.
static func clear_logs(keep_latest: bool = false) -> void:
	var da: DirAccess = DirAccess.open(_lp)
	da.list_dir_begin()
	var f: String = da.get_next()
	while f != "":
		if f != _cl and not (keep_latest and f == get_latest_log()):
			da.remove(f)
		f = da.get_next()
	da.list_dir_end()
## Log error.[br]
## [code]m[/code]: Log message.
static func e(m: String) -> void:
	_log("ERROR", m)
## Get the latest log in log path.[br]
## Returns the full filename of the latest log.
static func get_latest_log() -> String:
	var time: int = 0
	var da: DirAccess = DirAccess.open(_lp)
	da.list_dir_begin()
	var f: String = da.get_next()
	while f != "":
		if f.begins_with("log_") and f.ends_with(".log") and f != _cl:
			var t: int = int(f.substr(4, f.length() - 8))
			if t > time:
				time = t
		f = da.get_next()
	da.list_dir_end()
	return "log_%s.log" % String.num_uint64(time) if time > 0 else ""
## Log information.[br]
## [code]m[/code]: Log message.
static func i(m: String) -> void:
	_log("INFO", m)
## Log warning.[br]
## [code]m[/code]: Log message.
static func w(m: String) -> void:
	_log("WARN", m)
func _log_error(function: String, file: String, line: int, _code: String, rationale: String, _editor_notify: bool, _error_type: int, _script_backtraces: Array[ScriptBacktrace]) -> void:
	_log("ERROR", "at %s, func %s, line %s: %s" % [file, function, str(line), rationale])
func _log_message(message: String, error: bool) -> void:
	_log("ERROR" if error else "INFO", message)
