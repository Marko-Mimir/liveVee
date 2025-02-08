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

func select(val : bool) -> void:
	print("NO STATES")
	arm.target.position = arm.rest

func parseData() -> void:
	iName = data["name"]
	iDesc = data["description"]
	mass = data["mass"]
	

func _physics_process(delta: float) -> void:
	if held or grounded:
		return
	velocity += Vector2(0,1)*gravity*mass
	position += velocity*delta
		
	rotation = lerp(rotation, velocity.angle(), 0.1)

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
	sprite.material.set_shader_parameter("is_active", !sprite.material.get_shader_parameter("is_active"))
	outlined = sprite.material.get_shader_parameter("is_active")
