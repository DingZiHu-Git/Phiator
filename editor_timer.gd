extends Timer

func _ready() -> void:
	wait_time = Global.settings["autoSave"] if Global.settings["autoSave"] > 0 else 1
	if wait_time < 30:
		stop()
func _on_timeout() -> void:
	Global.save_chart()
	Global.make_notification(tr("auto_save_done"))
