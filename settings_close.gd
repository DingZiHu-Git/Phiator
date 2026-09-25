extends Panel

func _ready() -> void:
	$"../../../ScrollContainer".get_v_scroll_bar().custom_minimum_size.x = 24
	Global.get_settings()
	set_values()
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			self_modulate = Color.DARK_GRAY
		else:
			self_modulate = Color.WHITE
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			self_modulate = Color.DARK_GRAY
		elif event.is_released():
			self_modulate = Color.WHITE
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				Global.save_settings($"../../../ScrollContainer/HBoxContainer/Contents/Music".value, $"../../../ScrollContainer/HBoxContainer/Contents/SE".value, int($"../../../ScrollContainer/HBoxContainer/Contents/NotificationTime".value), $"../../../ScrollContainer/HBoxContainer/Contents/Background".selected, $"../../../ScrollContainer/HBoxContainer/Contents/Blur".value == 1, $"../../../ScrollContainer/HBoxContainer/Contents/Black".value, "rpe" if $"../../../ScrollContainer/HBoxContainer/Contents/Data".selected == 1 else "phiator", int($"../../../ScrollContainer/HBoxContainer/Contents/AutoSave".value), int($"../../../ScrollContainer/HBoxContainer/Contents/History".value), $"../../../ScrollContainer/HBoxContainer/Contents/SafeZone".value, $"../../../ScrollContainer/HBoxContainer/Contents/InterfaceScale".value)
				$"../../../..".visible = false
				$"../../../../..".load_interface_scale(Global.settings["interfaceScale"])
				$"../../../../../HBoxContainer/ScrollContainer/MarginContainer/ChartList".refresh()
func _on_music_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/Music".text = String.num(value)
func _on_se_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/SE".text = String.num(value)
func _on_notification_time_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/NotificationTime".text = String.num_uint64(int(value))
func _on_blur_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/Blur".text = tr("on") if value == 1 else tr("off")
func _on_black_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/Black".text = String.num(value)
func _on_auto_save_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/AutoSave".text = String.num_uint64(int(value)) + "s"
func _on_history_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/History".text = String.num_uint64(int(value))
func _on_safe_zone_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/SafeZone".text = String.num(value)
func _on_interface_scale_value_changed(value: float) -> void:
	$"../../../ScrollContainer/HBoxContainer/Values/InterfaceScale".text = String.num(value)
func set_values() -> void:
	$"../../../ScrollContainer/HBoxContainer/Contents/Music".value = Global.settings["music"]
	$"../../../ScrollContainer/HBoxContainer/Contents/SE".value = Global.settings["se"]
	$"../../../ScrollContainer/HBoxContainer/Contents/NotificationTime".value = Global.settings["notificationTime"]
	$"../../../ScrollContainer/HBoxContainer/Contents/Background".selected = Global.settings["background"]
	$"../../../ScrollContainer/HBoxContainer/Contents/Blur".value = 1 if Global.settings["blur"] else 0
	$"../../../ScrollContainer/HBoxContainer/Contents/Black".value = Global.settings["black"]
	$"../../../ScrollContainer/HBoxContainer/Contents/Data".selected = 1 if Global.settings["data"] == "rpe" else 0
	$"../../../ScrollContainer/HBoxContainer/Contents/AutoSave".value = Global.settings["autoSave"]
	$"../../../ScrollContainer/HBoxContainer/Contents/History".value = Global.settings["history"]
	$"../../../ScrollContainer/HBoxContainer/Contents/SafeZone".value = Global.settings["safeZone"]
	$"../../../ScrollContainer/HBoxContainer/Contents/InterfaceScale".value = Global.settings["interfaceScale"]
