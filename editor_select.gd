extends OptionButton

func _ready() -> void:
	Global.type = 0
	select(Global.type)
func _on_item_selected(index: int) -> void:
	Global.type = index
