extends OptionButton

func _on_item_selected(index: int) -> void:
	for i in get_parent().get_child_count():
		if i < 2:
			continue
		get_parent().get_child(i).visible = false
		if i == index + 2:
			get_parent().get_child(i).visible = true
