extends PanelContainer

var style = true
var pressed = false
func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	if style:
		if pressed:
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
		style = false
func _gui_input(event: InputEvent) -> void:
	if not pressed and event is InputEventMouseMotion:
		if Rect2(Vector2.ZERO, size).has_point(event.position):
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		else:
			add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
	elif not pressed and event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			add_theme_stylebox_override("panel", preload("res://button_pressed_stylebox.tres"))
		elif event.is_released():
			if Rect2(Vector2.ZERO, size).has_point(event.position):
				$"../RPE".pressed = false
				$"../RPE".style = true
				pressed = true
				style = true
			else:
				add_theme_stylebox_override("panel", preload("res://button_stylebox.tres"))
