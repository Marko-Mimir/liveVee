extends Node2D
class_name Arm
@export_subgroup("Groups")
@export var focus : Color
@export var unfocus : Color

@export_subgroup("Nodes")
@export var target : Node2D;
@export var hand : Node2D;
@export var shoulder : Marker2D

var held : equipable = null
var rest : Vector2
var isFlip : bool
var isSelected : bool = false:
	set(value):
		isSelected = value
		if held: held.select(value)
		if value:
			modulate = focus;
		else:
			modulate = unfocus
			if !held:target.position = rest;
			
var skeleton : Skeleton2D = null

func _ready() -> void:
	held = null
	player.onFlip.connect(flip)
	skeleton = get_node("Skeleton2D")
	rest = position
	rest.y += 12


func flip(_val : bool) -> void:
	z_index = z_index*-1
	if held:
		held.z_index=held.z_index*-1
	isFlip = _val
	
	#flip the magnet arroundsies
	var stack : SkeletonModificationStack2D = skeleton.get_modification_stack()
	var mod : SkeletonModification2DFABRIK = stack.get_modification(0)
	var magnet : Vector2 = mod.get_fabrik_joint_magnet_position(1)
	magnet.x = magnet.x*-1
	mod.set_fabrik_joint_magnet_position(1, magnet)
	stack.set_modification(0, mod)
	skeleton.set_modification_stack(stack)

func _process(_delta: float) -> void:
	if isSelected and !held:
		target.global_position = target.get_global_mouse_position()
		hand.rotation_degrees = 0
	if held:
		held.process()

func equip(item : equipable)-> void:
	item.held = true
	item.arm = self
	item.z_index= (abs(z_index)-1)*z_index/abs(z_index)
	item.grounded = false
	if item.outlined:
		item.outline()
	item.monitorable = false
	item.reparent(hand)
	item.position = Vector2.ZERO
	item.position = Vector2(item.offset, 0)
	held=item
	item.rotation_degrees = 0
	item.select(isSelected)
