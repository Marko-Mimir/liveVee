extends CharacterBody2D
class_name Player

var speed = 300
var jump_velocity = -400
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var groundedJump = true
var additionalJumps = 1;
var scene : liveScene = null;

#flip setter
var flip : bool = false:
	set(value):
		if value:
			sprite.scale.x = -1
		else:
			sprite.scale.x = 1
		flip = value
		onFlip.emit(value)

@export var coyoteTimer : Timer
@export var sprite : Sprite2D
@export var groundCast : RayCast2D

var LeftArm : Node2D
var head : Sprite2D
var RightArm : Node2D
var blink : Sprite2D
var blinkTimer : Timer
var isBlink : bool = false

var currentGround = null
var friction = .01;

var debug = false

#signals
signal onFlip(value : bool)
signal onClick(mouseEvent : InputEventMouseButton)

var manager : ItemManager;

func _ready():
	blinkTimer = get_node("blink")
	LeftArm = get_node("leftArm")
	RightArm = get_node("rightArm")
	head = get_node("body/head")
	blink = get_node("body/blink")
	manager = get_node("equipableManager")
	coyoteTimer.timeout.connect(coyoteTimeout)

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
	
	if mouse.y < -35:
		head.frame=1
	elif mouse.y > 10:
		head.frame=2
	else:
		head.frame = 0
	
	#debug stuff
	if Input.is_action_just_pressed("debug"):
		debug = !debug
	if debug:
		if Input.is_action_just_pressed("jump") and scene: #Show debug collision blocks
			scene.debug_collision_shape_visibility()
		if Input.is_action_just_pressed("die") and scene: #Zoom in/out camera
			if scene.camera.zoom == Vector2(1,1):
				scene.camera.zoom = Vector2(2,2);
				return
			scene.camera.zoom = Vector2(1,1)
		if Input.is_action_just_pressed("leftMouse"): #teleport arround
			global_position = get_global_mouse_position()
			velocity.y = 0
		if Input.is_action_just_pressed("down"): #stop graity
			velocity.y = 0
			if gravity == 0:
				gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			else:
				gravity = 0
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			onClick.emit(event)

func blinkTimeout() -> void:
	if isBlink:
		blink.visible = false;
		isBlink=false;
		blinkTimer.wait_time = randf_range(1,4)
		blinkTimer.start()
		return
	blink.frame = head.frame
	blink.visible = true
	blinkTimer.wait_time = 0.1
	isBlink=true
	blinkTimer.start()
	
