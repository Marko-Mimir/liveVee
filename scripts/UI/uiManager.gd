extends Node

var currentUi := {}

func add_ui(lui : LiveUi):
	if currentUi.keys().has(lui.id):
		print_rich(util.translateAltColorCodes("&", ('UI (&c'+lui.id+'&r) already present. returning')))
		return
	add_child(lui)
	currentUi[lui.id] = lui

func remove_ui(id : String) -> Error:
	if currentUi.has(id):
		currentUi[id].queue_free()
		currentUi.erase(id)
		return OK
	return FAILED

func remove_ui_by_instance(instance : LiveUi) -> Error:
	var key = currentUi.find_key(instance)
	if key != null:
		currentUi[key].queue_free()
		currentUi.erase(key)
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
	for x in currentUi.keys():
		currentUi[x].queue_free()
		currentUi.erase(x)
	
