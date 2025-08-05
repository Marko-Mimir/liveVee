extends Node2D
class_name ItemManager

@export var detector : Area2D = null

var overlap : Array[Area2D] = []
var nearest : Area2D = null

var LeftArm : Arm = null
var RightArm : Arm = null
var isFocus := false;
var lastSelect : Arm = null

func _ready() -> void:
	RightArm = get_node("../rightArm")
	LeftArm = get_node("../leftArm")
	LeftArm.isSelected = true
	player.onClick.connect(click)

func unfocus() -> void:
	if isFocus:
		lastSelect.isSelected = true
		isFocus = false
		return
	isFocus = true
	if RightArm.isSelected:
		RightArm.isSelected = false
		lastSelect = LeftArm
	else:
		LeftArm.isSelected = false
		lastSelect = LeftArm

func click(e : InputEventMouseButton) -> void:
	if(isFocus): return
	match e.get_button_index():
		1:
			if !LeftArm.isSelected:
				LeftArm.isSelected = true
				RightArm.isSelected = false
			elif LeftArm.held:
				pass #usage
			if nearest != null and !Input.is_action_pressed("throw"):
				if LeftArm.held != null:
					LeftArm.dequip(Vector2((.5*(LeftArm.z_index/abs(LeftArm.z_index))*-1),-.5)*300)
				LeftArm.equip(nearest)
				hideEquipment(nearest)
		2:
			if !RightArm.isSelected:
				LeftArm.isSelected = false
				RightArm.isSelected = true
			elif RightArm.held:
				pass #usage
			if nearest != null and !Input.is_action_pressed("throw"):
				if RightArm.held != null:
					RightArm.dequip(Vector2((.5*(RightArm.z_index/abs(RightArm.z_index))),-.5)*300)
				RightArm.equip(nearest)
				hideEquipment(nearest)
		

func _draw() -> void:
	pass

func _get_selected_arm() -> Array[Arm]:
	if RightArm.isSelected:
		return [RightArm, LeftArm]
	return [LeftArm, RightArm]
	

#outline stuff
func seeEquipment(area: Area2D) -> void:
	overlap.append(area)
	updateVisible()

func hideEquipment(area: Area2D) -> void:
	overlap.pop_at(overlap.find(area))
	if area.outlined:
		area.outline()
		if area == nearest:
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
