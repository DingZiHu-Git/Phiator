extends PanelContainer

var selected: String = "res://respack/PhiatorOfficial.zip"
func _ready() -> void:
	$VBoxContainer/ScrollContainer.get_v_scroll_bar().custom_minimum_size.x = 32
	if not DirAccess.dir_exists_absolute(Global.DIR + "skins"):
		DirAccess.make_dir_recursive_absolute(Global.DIR + "skins")
		var faw := FileAccess.open(Global.DIR + "skins/selected", FileAccess.WRITE)
		faw.store_string("res://respack/PhiatorOfficial.zip")
		faw.close()
	var far := FileAccess.open(Global.DIR + "skins/selected", FileAccess.READ)
	selected = far.get_as_text()
	far.close()
	refresh()
func refresh() -> void:
	var skins := $VBoxContainer/ScrollContainer/VBoxContainer
	for i in skins.get_children():
		i.queue_free()
	var po := preload("res://skin.tscn").instantiate()
	po.get_node(^"Text/HBoxContainer/Delete").visible = false
	skins.add_child(po)
	var da := DirAccess.open(Global.DIR + "skins")
	da.list_dir_begin()
	var f := da.get_next()
	while f != "":
		if f.to_lower().ends_with(".zip"):
			var skin := preload("res://skin.tscn").instantiate()
			skin.path = da.get_current_dir() + "/" + f
			skins.add_child(skin)
		f = da.get_next()
	da.list_dir_end()
	for i in skins.get_children():
		if i.path == selected:
			apply(i)
func apply(skin: HBoxContainer) -> void:
	selected = skin.path
	Global.skin = skin.skin
	var fa := FileAccess.open(Global.DIR + "skins/selected", FileAccess.WRITE)
	fa.store_string(skin.path)
	fa.close()
	
