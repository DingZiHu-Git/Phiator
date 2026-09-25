extends SpinBox

var init
func _ready() -> void:
	init = true
func _process(_delta: float) -> void:
	if init:
		var node = get_child(0, true)
		if node is LineEdit:
			node.caret_blink = true
			node.caret_blink_interval = 0.5
			node.virtual_keyboard_show_on_focus = false
			init = false
