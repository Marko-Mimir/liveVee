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

func wipe() -> void:
	for x in currentUi:
		currentUi[x].queue_free()
	
