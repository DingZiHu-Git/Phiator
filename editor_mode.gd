extends PanelContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
	elif event is InputEventScreenTouch:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		elif event.is_released():
			add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				Global.mode += 1
				if Global.mode == 3:
					Global.mode = 0
				match Global.mode:
					0:
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Note".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Note".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Event".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Event".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Note".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Note".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Event".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Event".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Event".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Event".size_flags_horizontal = SIZE_EXPAND_FILL
						$Label.text = tr("note_event")
					1:
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Note".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Note".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Event".visible = false
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Event".size_flags_horizontal = SIZE_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Note".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Note".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Event".visible = false
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Event".size_flags_horizontal = SIZE_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Event".visible = false
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Event".size_flags_horizontal = SIZE_FILL
						$Label.text = tr("note")
					2:
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Note".visible = false
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Note".size_flags_horizontal = SIZE_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Event".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/ScrollContainer/HBoxContainer/Event".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Note".visible = false
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Note".size_flags_horizontal = SIZE_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Event".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/HLines/HBoxContainer/Event".size_flags_horizontal = SIZE_EXPAND_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".visible = false
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".size_flags_horizontal = SIZE_FILL
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Event".visible = true
						$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Event".size_flags_horizontal = SIZE_EXPAND_FILL
						$Label.text = tr("event")
				$"../../../Control/PanelContainer/AspectRatioContainer/Lines/Note".refresh.call_deferred()
				$"../../../../..".reload_deferred()
