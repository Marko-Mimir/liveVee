extends CharacterBody2D
class_name Player

#dear future code readers, this is a mess i cant even lie, I spent a lot of this project learning godot and
#unfortunately it turned into this hell that is player.gd have fun looking through this and feel free to msg
#me if a) you found this b) have any critiques as this is very IMPORTANT to have feel right a lot of this is 
#subject to change idk yeah, anywhoo, have fun reading a bunch of broken up player scripts lol, 
# pls dont judge the equipment manager by far the first thing I made all the way in 2024 i think
# anywhoo, signing off - Marko/Restine 6.2.2025

var speed = 300
var jump_velocity = -400
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var groundedJump = true
var additionalJumps = 1;
var scene : liveScene = null;
var smear : Sprite2D

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

var speakBox : Area2D;

var currentGround = null
var smearArea : Area2D;
var friction = .2;
var holdingJump = false

##Area of Interest, set this to make the player automatically move towards it unless the player presses ANY button.
var aoi : AOI = null

var chat : PlayerChat

var debug = false
var debugCheck:
	get():
		return true;

#signals
signal onFlip(value : bool)
signal onClick(mouseEvent : InputEventMouseButton)

var manager : ItemManager;
var inventory : Inventory;
var s = 0

func _ready():
	inventory = get_node("InvStorage")
	speakBox = get_node("speakBox")
	smear = get_node("smear")
	smearArea = get_node("smear/smearArea")
	blinkTimer = get_node("blink")
	LeftArm = get_node("leftArm")
	RightArm = get_node("rightArm")
	head = get_node("body/head")
	blink = get_node("body/blink")
	manager = get_node("equipableManager")
	chat = get_node("chatManager")
	coyoteTimer.timeout.connect(coyoteTimeout)
	

func coyoteTimeout() -> void:
	groundedJump = false

func set_aoi(target : AOI):
	aoi = target

func _physics_process(delta):
	if aoi:
		velocity.y += (gravity * delta)
		if can_interact(aoi):
			aoi.action.emit()
			aoi=null
			return
		if aoi.global_position.x > global_position.x:
			s = lerpf(s, 300.0, .1)
			velocity.x = (1 * s)
		else:
			s = lerpf(s, 300.0, .1)
			velocity.x = (-1 * s)
		move_and_slide()
		return
	
	if not is_on_floor():
		if Input.is_action_just_released("jump"):
			holdingJump = false
		if !holdingJump and velocity.y < 0:
			velocity.y = lerpf(velocity.y, 0.0, .5)
		if Input.is_action_pressed("down"):
			velocity.y += 10
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
			holdingJump = true;
			velocity.y = jump_velocity
			if not groundedJump:
				additionalJumps -= 1
	
	var direction = Input.get_axis("left", "right")
	if direction:
		s = lerpf(s, 300.0, .1)
		velocity.x = (direction * s)
	else:
		velocity.x = (move_toward(velocity.x, 0, speed*friction))
		s = 0
	
	move_and_slide()

func can_interact(area : Area2D)-> bool:
	if area in speakBox.get_overlapping_areas():
		return true;
	return false;

func _process(_delta):
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
	if Input.is_action_just_pressed("fullscreen"):
		if DisplayServer.window_get_mode() != DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else: DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	
	if Input.is_action_just_pressed("debug"):
		debug = !debug
	if debug:
		if Input.is_action_just_pressed("jump") and scene: #Show debug collision blocks
			scene.debug_collision_shape_visibility()
		if Input.is_action_just_pressed("die") and scene: #reset camera zoom
			scene.camera.zoom = Vector2(1,1)
		if Input.is_action_just_pressed("leftMouse"): #teleport arround
			global_position = get_global_mouse_position()
			velocity.y = 0
		if Input.is_action_just_pressed("rightMouse"): #Wipe UI
			ui.wipe()
		if Input.is_action_just_pressed("down"): #stop graity
			velocity.y = 0
			if gravity == 0:
				gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
			else:
				gravity = 0
		if Input.is_action_pressed("midmouse"): # smooth camera zoom
			var w = scene.camera.windowBounds
			var m : Vector2 = get_window().get_mouse_position()
			var y = m.y/w.y
			y = clamp(y, 0, 1)+1
			var i = snapped(lerpf(scene.camera.zoom.x, y, .05), 0.01)
			scene.camera.zoom.x = i
			scene.camera.zoom.y = scene.camera.zoom.x

func collect(item : Dictionary, type : int) -> void:
	print(item)
	print(type)
	if type == liveCollectable.types.BLUEPRINT:
		#Blueprint Specificity
		print("BP COLLECT")
		inventory.getBlueprint(int(item["data"]))
	pass

func _input(event: InputEvent) -> void:
	if aoi and event is InputEventKey and event.is_echo() == false:
		aoi = null
		return
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
	
