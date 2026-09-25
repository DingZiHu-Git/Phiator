extends TextureButton

var player: AspectRatioContainer
func _ready() -> void:
	player = $"../../../../../Player"
func _toggled(toggled_on: bool) -> void:
	(player.start if toggled_on else player.stop).call()
func _on_progress_drag_started() -> void:
	player.stop()
	button_pressed = false
