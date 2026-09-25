extends Panel

var player: AspectRatioContainer
var pause: Node
func _ready() -> void:
	player = $"../../.."
func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.is_released():
		if player.mode < 2:
			if modulate.a > 0.0:
				player.stop()
				pause.visible = true
				modulate.a = 0.0
			else:
				modulate.a = 1.0
				get_tree().create_timer(3.0).timeout.connect(func():
					modulate.a = 0.0
				)
