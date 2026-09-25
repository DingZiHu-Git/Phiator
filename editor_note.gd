extends Control

var lines: int = 21
func refresh(v_lines: int = -1) -> void:
	if v_lines != -1:
		lines = v_lines
	for i in get_children():
		i.queue_free()
	for i in lines:
		var color = ColorRect.new()
		color.offset_transform_enabled = true
		color.offset_transform_position_ratio.x = -0.5
		color.color = Color.YELLOW
		color.custom_minimum_size.x = 2
		color.anchor_bottom = 1
		color.position.x = (i + 1) / (float(lines + 1)) * size.x
		add_child(color)
	var line = ColorRect.new()
	line.offset_transform_enabled = true
	line.offset_transform_position_ratio.x = -0.5
	line.color = Color.AQUA
	line.custom_minimum_size.x = 2
	line.anchor_bottom = 1
	line.position.x = size.x / 2
	add_child(line)
