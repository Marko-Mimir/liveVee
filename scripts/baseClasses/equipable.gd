extends Area2D
class_name equipable

@export var handle : Node2D = null
@export var IgnoreReady : bool = false;
@export var itemId : int = -1
@export var settings := equipableSettings.new()

#data
var itemPath = "res://resources/items.json"
var data : Dictionary
var iName : String
var iDesc : String
var states : Dictionary = {}
var isAttacking
var dontAttack := false

#gravity
var mass : float = 0.15
var velocity : Vector2;

#player interaction
var held : bool = false
var grounded : bool = false
var offset : float

var sprite : Sprite2D
var outlined : bool = false
var arm : Arm = null

signal usageDirection(use : equipableUsage)

func flipDeg(deg : int)-> float:
	if deg == 0:
		print("PEOW")
		deg = 1
	var isNeg : float = deg/abs(deg)
	var flip = 180-abs(deg)
	return flip*isNeg

func _ready() -> void:
	z_index = -3
	if itemId == -1:
		print_rich("[b]ITEM ID NOT SET")
		queue_free()
		return
	#json setup
	var file = FileAccess.open(itemPath, FileAccess.READ)
	var content = file.get_as_text()
	data = JSON.parse_string(content)[str(itemId)]
	parseData()
	#check for sprite2d
	if has_node("sprite"):
		sprite = get_node("sprite")
	else:
		print_rich("[color=red][Error] "+name+"[/color]- I have no sprite. Deleting")
		queue_free()
		return
	for x in settings.states:
		states[x.name] = x
	body_entered.connect(hit)
	offset = -handle.position.x
	onReady();

func onReady() -> void:
	if IgnoreReady: return;
	push_warning("non-default onready statement. Click flag \"Ignore Ready\" in 
	the inspector if you wish to get rid of this.")

func process() -> void:
	print("OVER-WRITE THIS IN SUBCLASS")
	if arm.isSelected:
		arm.target.global_position = arm.target.get_global_mouse_position()
		arm.hand.rotation_degrees = 0

func select(_val : bool) -> void:
	print("NO STATES")
	arm.target.position = arm.rest

func _input(event: InputEvent) -> void: #DIRECTION DETECTOR
	if !arm or !arm.isSelected: return
	if player.manager.nearest: return
	if dontAttack: return;
	if event.is_action_pressed(arm.action):
		#DIRECTION PARSER
		var vec  = (get_global_mouse_position() - arm.shoulder.global_position).normalized()
		var possible = []
		if vec.y < 0: possible = [0,1,2]
		else: possible = [5,6,7]
		if vec.x < 0: 
			possible.append(3)
			possible.pop_at(2)
			possible = [possible[1],possible[0],possible[2]]
		else: 
			possible.append(4)
			possible.pop_at(0)
		#structure is (D/U, CARDNAL, R/L)
		var mouse = arm.shoulder.get_local_mouse_position()
		var final = []
		if abs(vec.x) > .4 and abs(vec.y) > .4:
			final.append(possible[1])
		if abs(mouse.x) > abs(mouse.y): # MORE L/R
			final.append(possible[2])
			if final[0] != possible[1]: final.append(possible[1])
			final.append(possible[0])
		else: # MORE U/D
			final.append(possible[0])
			if final[0] != possible[1]: final.append(possible[1])
			final.append(possible[2])
		#USAGE PARSER
		var usage = settings.usages
		var maybe = [null,null,null]
		#first is perfect, second is next best, third is okay.
		for use in usage:
			var dirs = use.directions
			for x in dirs:
				if x == final[0]:
					maybe[0] = use
					break
				if x == final[1]:
					maybe[1] = use
					break
				if x == final[2]:
					maybe[2] = use
					break
		for x in maybe:
			if x != null: 
				usageDirection.emit(x); 
				return
		usageDirection.emit(null)

func parseData() -> void:
	iName = data["name"]
	iDesc = data["description"]
	mass = data["mass"]

func _physics_process(delta: float) -> void:
	if held or grounded:
		return
	velocity += Vector2(0,1)*gravity*mass
	position += velocity*delta
	
	rotation = lerp_angle(rotation, velocity.angle(), 0.1)

func hit(area : Node):
	if area.name == "player":
		return;
	if grounded: return;
	grounded = true
	velocity = Vector2(0,0)

func wake(value : bool) -> void:
	if value:
		modulate = Color(255,255,255,1)
	else:
		modulate = Color(200,200,200,1)

func outline():
	if sprite.material == null:
		push_warning("sprite has no outline shader attached, add a shader material.")
		return;
	if !sprite.material.has_method("set_shader_parameter"):
		push_warning("Sprite has wrong type of material attached.")
		return
	if outlined:
		sprite.material.set_shader_parameter("strength", 0.0)
		outlined = false
	else:
		sprite.material.set_shader_parameter("strength", 1.0)
		outlined = true
