extends Node2D
class_name ItemManager

@export var detector : Area2D = null

var overlap : Array[Area2D] = []
var nearest : Area2D = null

var LeftArm : Arm = null
var RightArm : Arm = null

func _ready() -> void:
	RightArm = get_node("../rightArm")
	LeftArm = get_node("../leftArm")
	LeftArm.isSelected = true
	player.onClick.connect(click)
	
func click(e : InputEventMouseButton) -> void:
	match e.get_button_index():
		1:
			if !LeftArm.isSelected:
				LeftArm.isSelected = true
				RightArm.isSelected = false
			elif LeftArm.held:
				print('useage')
			if LeftArm.held == null and nearest != null:
				LeftArm.equip(nearest)
				hideEquipment(nearest)
		2:
			if !RightArm.isSelected:
				LeftArm.isSelected = false
				RightArm.isSelected = true
			elif RightArm.held:
				print('useage')
			if RightArm.held == null and nearest != null:
				RightArm.equip(nearest)
				hideEquipment(nearest)
		

#outline stuff
func seeEquipment(area: Area2D) -> void:
	overlap.append(area)
	updateVisible()

func hideEquipment(area: Area2D) -> void:
	overlap.pop_at(overlap.find(area))
	if area.outlined:
		area.outline()
		nearest = null
	updateVisible()

func updateVisible() -> void:
	if overlap.is_empty():
		return
	if len(overlap) > 1:
		var last = null
		for x in overlap:
			var r = x.global_position.distance_squared_to(global_position)
			if last == null or last < r:
				last = r
				nearest= x
		for x in overlap:
			if x != nearest and x.outlined:
				x.outline()
	else:
		nearest = overlap[0]
	if !nearest.outlined:
		nearest.outline()
