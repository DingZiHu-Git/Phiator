extends AspectRatioContainer

func _ready() -> void:
	_on_resized()
	$TextureRect.texture = $Player/Illustration.texture
	$Player.set_mode(1)
	$Player/MarginContainer/Control/Panel.pause = $Pause
func _on_resized() -> void:
	ratio = size.x / size.y
