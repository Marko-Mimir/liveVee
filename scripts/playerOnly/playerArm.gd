extends Node2D
class_name Arm
@export_subgroup("Groups")
@export var focus : Color
@export var unfocus : Color
@export var action : String

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
	global_rotation_degrees = 0


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

func dequip(velocity := Vector2(0,0))->void:
	held.held = false
	held.arm = null
	held.z_index = abs(z_index)
	held.monitorable = true
	held.reparent(player.scene)
	held.velocity = velocity
	held = null
	queue_redraw()
	return 

func _draw() -> void:
	if !held:
		return
	if !Input.is_action_pressed("throw"):
		return
	if !isSelected:
		return
	var tar = target.get_local_mouse_position()
	var v : Vector2 = -(target.position - tar).normalized()
	v = v*300
	
	var t = 0.05
	var colors = [Color.RED, Color.BLUE]
	var start = target.position
	var end : Vector2;
	for i in range(12):
		end = start
		v += Vector2(0,1)*98*0.15
		end += v*t
		
		draw_line(start,end, colors[i%2],2)
		start = end

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
