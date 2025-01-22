extends Node
class_name ItemManager

var LeftHeld : equipable = null
var RightHeld : equipable = null

func equip(item : equipable, sLeft : bool = false):
	pass

func dequip(isLeft : bool = false) -> equipable:
	return equipable.new();
