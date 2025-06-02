extends Node

var currentUi := {}

func add_ui(lui : LiveUi):
	add_child(lui)
	currentUi[lui.id] = lui

func remove_ui(id : String) -> Error:
	if currentUi.has(id):
		currentUi[id].queue_free()
		return OK
	return FAILED

func get_ui(id : String) -> LiveUi:
	if currentUi.has(id):
		return currentUi[id]
	return null

func get_or_add(id: String, path : String) -> LiveUi:
	if currentUi.has(id):
		return currentUi[id]
	var lui = load(path).instantiate()
	add_child(lui)
	currentUi[lui.id] = lui
	return lui

func has_ui(id : String) -> bool:
	return currentUi.has(id)

func wipe() -> void:
	for x in currentUi:
		currentUi[x].queue_free()
	currentUi = {}
	
