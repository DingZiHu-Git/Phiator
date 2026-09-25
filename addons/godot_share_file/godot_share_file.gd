extends Node
const SINGLETON := "GodotShareFile"
signal file_received(path: String)
func share(path: String) -> void:
	if not Engine.has_singleton(SINGLETON):
		push_error("GodotShareFile not loaded (non-Android?)")
		return
	Engine.get_singleton(SINGLETON).share(path)