extends TextureButton

func _toggled(toggled_on: bool) -> void:
	$"../../PanelContainer".modulate.a = 1.0 if toggled_on else 0.0
	self_modulate = Color.WHITE if toggled_on else Color.DARK_GRAY
