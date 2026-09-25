extends Label

var timer: Timer
func _ready() -> void:
	timer = $Timer
	rand()
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.is_released():
		rand()
func rand() -> void:
	Global.tip += 1
	text = "Tip: " + tr("tip" + String.num_uint64(randi_range(1, 65))).format({"num":Global.tip})
	timer.start()
