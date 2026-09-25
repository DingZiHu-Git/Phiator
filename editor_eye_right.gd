extends TextureButton

func _toggled(toggled_on: bool) -> void:
	$"../Properties".visible = toggled_on
	self_modulate = Color.WHITE if toggled_on else Color.DARK_GRAY
