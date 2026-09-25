extends ScrollContainer

@onready var interval = $"../../../Operations/ScrollContainer/MarginContainer/VBoxContainer/Interval"
@onready var progress = $"../../../../PanelContainer/Operations/Progress"
func _ready() -> void:
	pass
func _process(_delta: float) -> void:
	pass
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		$"../../../../../../Player/Music".stop()
		$"../../../../PanelContainer/Operations/Play".button_pressed = false
		var bpm: float = 0
		for i in Global.bpm:
			if progress.value >= i["time"]:
				bpm = i["bpm"]
		progress.value += event.screen_relative.y / interval.value / $"../../../../..".size.y / bpm * 60
	elif event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
			progress.value -= 100 * interval.value
		elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			progress.value += 100 * interval.value
