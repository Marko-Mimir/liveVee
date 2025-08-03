extends Node
class_name Inventory

var allItems : Dictionary
var CurInv : Dictionary = {}
var InvBlueprints : Array[int];
enum Types {BLUEPRINT}

func _ready() -> void:
	allItems = util.loadJson("res://resources/collectables.json")

func getPlayerInventory() -> Dictionary:
	return CurInv

func search(type, id = null, hasMeta = null ):
	if !str(type) in CurInv.keys(): #invalid type, returns [] as a failsafe
		return []
	var qTypes = []
	var qFin = []
	if type == "*":
		qTypes = [Types.BLUEPRINT]
	else:
		qTypes.append(Types.get(type))
	#UNFINISHED TODO: Add id searching, then hasMeta searching.

func getItems(type : Types, hasMeta = null) -> Array:
	if !str(type) in CurInv.keys():
		player.scene.gamePrint("Invalid {type}, returning []")
		return []
	if hasMeta:
		var fin = []
		for val in CurInv[str(type)].values():
			if "meta" in val.keys():
				if val["meta"] == hasMeta:
					fin.append(val)
		return fin
	return CurInv[str(type)].keys()
#VALID {item} syntax {"type":0,"id":0} type corelates to the Types enum, and id is specific per type. Equipables do not count as a collectable

func addItem(item : Dictionary, withMeta = null):
	var dat = util.getCollectableData(item)
	if withMeta:
		dat["meta"] = withMeta
	var id = str(item["id"])
	if CurInv.has(str(item["type"])):
		CurInv[str(item["type"])].set(id, dat)
	else:
		CurInv.set(str(item["type"]), {})
		CurInv[str(item["type"])].set(id,dat)
	player.scene.gamePrint("+1 "+dat["name"])

func getBlueprint(bpid : int):
	addItem({"id":"0","type":"-1"}) #Add a debug "Unknown Blueprint"
	InvBlueprints.append(bpid)

func hasItem(_item)-> bool:
	return false

func removeItem(_item):
	pass
