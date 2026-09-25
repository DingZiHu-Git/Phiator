@tool
extends EditorPlugin
const PLUGIN_AUTOLOAD_NAME = "ShareFile"
var _export_plugin: AndroidExportPlugin
func _enter_tree() -> void:
	_export_plugin = AndroidExportPlugin.new()
	add_export_plugin(_export_plugin)
	add_autoload_singleton(PLUGIN_AUTOLOAD_NAME, "res://addons/godot_share_file/godot_share_file.gd")
func _exit_tree() -> void:
	remove_export_plugin(_export_plugin)
	remove_autoload_singleton(PLUGIN_AUTOLOAD_NAME)
	_export_plugin = null
class AndroidExportPlugin extends EditorExportPlugin:
	var _plugin_name = "GodotShareFile"
	func _supports_platform(platform: EditorExportPlatform) -> bool:
		if platform is EditorExportPlatformAndroid:
			return true
		return false
	func _get_android_libraries(platform: EditorExportPlatform, debug: bool) -> PackedStringArray:
		if debug:
			return PackedStringArray(["res://addons/godot_share_file/bin/debug.aar"])
		else:
			return PackedStringArray(["res://addons/godot_share_file/bin/release.aar"])
	func _get_name() -> String:
		return _plugin_name