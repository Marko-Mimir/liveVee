extends Node

var completeCollection := {}
var currentCollection := {"friends":{},"cast":{},"equip":{}}

func queryFriendship(obj : String)->int:
	var current = currentCollection["friends"].get_or_add(obj, 0)
	if util.isNeg(current):
		return -1
	#TODO: add friendship gates, idk how much, 300 = friend 1? or maybe it should be exponensial? like 1=200, 2=500, 3= 1000, 4 = 1700, 5= 3000?
	# maybe 250/level might be easier to code.
	return 0

func editFriendship(obj : String, ammt : int):
	var curFriend :int= currentCollection["friends"].get_or_add(obj, 0)
	curFriend+=ammt;
	currentCollection["friends"].set(obj,curFriend)

func _ready() -> void:
	#generate collection
	completeCollection = util.loadJson("res://resources/json/collectables.json")

func collect(item : LiveItem):
	print(item.data)
	print(item.item)
