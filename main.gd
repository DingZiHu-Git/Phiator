extends AspectRatioContainer

func _ready() -> void:
	Log.i("MAIN: Start loading...")
	$HBoxContainer/Operations.get_v_scroll_bar().custom_minimum_size.x = 28
	Global.notifications = $Notifications/Control
	Global.fps = $Info/FPS
	$HBoxContainer/ScrollContainer/MarginContainer/ChartList.refresh()
	load_interface_scale.call_deferred(Global.settings["interfaceScale"])
func _on_resized() -> void:
	ratio = size.x / size.y
## Set the safe zone to the given value [code]safe_zone[/code].[br]
## [code]safe_zone[/code]: The size of the main scene on the screen.
func load_safe_zone(safe_zone: float) -> void:
	var parent := $".."
	var ps: Vector2 = parent.size
	parent.remove_theme_constant_override(&"margin_bottom")
	parent.remove_theme_constant_override(&"margin_left")
	parent.remove_theme_constant_override(&"margin_right")
	parent.remove_theme_constant_override(&"margin_top")
	parent.add_theme_constant_override(&"margin_bottom", (ps.y - ps.y * safe_zone) / 2)
	parent.add_theme_constant_override(&"margin_left", (ps.x - ps.x * safe_zone) / 2)
	parent.add_theme_constant_override(&"margin_right", (ps.x - ps.x * safe_zone) / 2)
	parent.add_theme_constant_override(&"margin_top", (ps.y - ps.y * safe_zone) / 2)
## Set the interface scale to the given value [code]interface_scale[/code].[br]
## [code]interface_scale[/code]: The scale of the contents.
func load_interface_scale(interface_scale: float) -> void:
	get_tree().root.content_scale_factor = interface_scale
	load_safe_zone.call_deferred(Global.settings["safeZone"])
