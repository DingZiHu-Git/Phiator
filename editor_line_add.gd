extends PanelContainer

func _ready() -> void:
	pass
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
				Global.loaded["line"].append({
					"bpmFactor": 1.0,
					"cover": true,
					"event": [
						{
							"alpha": [
								{
									"beat": [
										[ 0, 0, 1 ],
										[ 1, 0, 1 ]
									],
									"ease": 0,
									"transition": 0,
									"value": [ 0.0, 0.0 ]
								}
							],
							"rotate": [
								{
									"beat": [
										[ 0, 0, 1 ],
										[ 1, 0, 1 ]
									],
									"ease": 0,
									"transition": 0,
									"value": [ 0.0, 0.0 ]
								}
							],
							"speed": [
								{
									"beat": [
										[ 0, 0, 1 ],
										[ 1, 0, 1 ]
									],
									"ease": 0,
									"transition": 0,
									"value": [ 1.0, 1.0 ]
								}
							],
							"x": [
								{
									"beat": [
										[ 0, 0, 1 ],
										[ 1, 0, 1 ]
									],
									"ease": 0,
									"transition": 0,
									"value": [ 0.0, 0.0 ]
								}
							],
							"y": [
								{
									"beat": [
										[ 0, 0, 1 ],
										[ 1, 0, 1 ]
									],
									"ease": 0,
									"transition": 0,
									"value": [ 0.0, 0.0 ]
								}
							]
						}
					],
					"father": -1,
					"note": [],
					"texture": "",
					"ui": 0
				})
				$"../Line".max_value += 1
				$"../Line".value = $"../Line".max_value
				$"../../../../../../../../Player".reload()
				$"../../../../../../../..".reload()
