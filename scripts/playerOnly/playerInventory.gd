extends Node
class_name Inventory

var CurInv : Dictionary = {}

func getPlayerInventory() -> Dictionary:
	return CurInv

func getItems(id : int) -> int:
	return CurInv[id] #returns ammound i think

func addItem(item : int):
	CurInv.set(item, CurInv.get_or_add(item, 0)+1)
	print(CurInv)

func hasItem(id:int)-> bool:
	return CurInv.has(id)

func removeItem(_id:int):
	pass
