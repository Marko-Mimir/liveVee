extends CharacterBody2D
class_name Player

var speed = 300
var jump_velocity = -400
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var groundedJump = true
var additionalJumps = 1;
var scene : liveScene = null;
var skeleton : Skeleton2D;

#flip setter
var flip : bool = false:
	set(value):
		sprite.flip_h = value
		flip = value
		if swordManager.currentSword:
			swordManager.currentSword.flip(value)
		var fabrIk :SkeletonModification2DFABRIK = skeleton.get_modification_stack().get_modification(0)
		if value == true:
			fabrIk.set_fabrik_joint_magnet_position(1, Vector2(.01,20))
		else:
			fabrIk.set_fabrik_joint_magnet_position(1, Vector2(-.01,20))

@export var coyoteTimer : Timer
@export var sprite : Sprite2D
@export var groundCast : RayCast2D

var swordManager : SwordManager
var currentGround = null
var friction = .01;

var debug = false

#signals
signal attack_input(isStrong)

func get_fabrik():
	var fabrIk :SkeletonModification2DFABRIK = skeleton.get_modification_stack().get_modification(0)
	return fabrIk

func _ready():
	swordManager =get_node("swordManager")
	skeleton = get_node("arm/Skeleton2D")
	coyoteTimer.timeout.connect(coyoteTimeout)
	
	var packedSword : PackedScene= load("res://objects/dummySword.tscn")
	var sword = packedSword.instantiate()
	swordManager.add_sword(sword)

func coyoteTimeout() -> void:
	groundedJump = false

func _physics_process(delta):
	if not is_on_floor():
		#Do gravity
		velocity.y += (gravity * delta)
		#Start coyote time if off ground and groundedJump = true
		if coyoteTimer.is_stopped() and groundedJump:
			coyoteTimer.start()
	else:
		#reset jumpts
		if not groundedJump:
			groundedJump = true
		additionalJumps = 1
	
	if Input.is_action_just_pressed("jump"): #Jump handeling, for both multijumps and grounded jump
		if groundedJump or additionalJumps > 0:
			velocity.y = jump_velocity
			if not groundedJump:
				additionalJumps -= 1
	
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = (direction * speed)
	else:
		velocity.x = (move_toward(velocity.x, 0, speed*friction))
	
	move_and_slide()

func _process(_delta):	
	#check ground type
	var result = groundCast.get_collider()
	if result == null and currentGround != null:
		friction = .25
		currentGround = result
	elif result != currentGround:
		friction = result.get_meta("Friction", 0.08)
		currentGround = result
	
	#flip
	var mouse : Vector2 = get_local_mouse_position()
	if mouse.x > 0 and flip:
		flip = false
	elif mouse.x < 0 and not flip:
		flip = true
	
	#Attack
	if Input.is_action_just_pressed("n_attack"):
		attack_input.emit(false)
	if Input.is_action_just_pressed("s_attack"):
		attack_input.emit(true)
	
	#debug stuff
	if Input.is_action_just_pressed("debug"):
		debug = !debug
	if debug:
		if Input.is_action_just_pressed("jump") and scene:
			scene.debug_collision_shape_visibility()
		if Input.is_action_just_pressed("n_attack"):
			global_position = get_global_mouse_position()
		if Input.is_action_just_pressed("down"):
			velocity.y = 0
			if gravity == 0:
				gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			else:
				gravity = 0
	
