extends CharacterBody2D
class_name Character

@export var character : Node2D
@export var attackTimer : Timer
@export var attackAnimator : AnimationPlayer
@export var arm : Marker2D
const SPEED = 500.0
const JUMP_VELOCITY = -400.0
var stop = false;
var canJump = false;
var coyoteTimer : Timer;
var additionalJumps : int = 1
var slashint = 1
var damMin = 10
var damMax = 25
var damSour = 7
var slashCounter = 0
var timescale : float = 1.0
var flip: bool = false:
	set(value):
		if (flip != value):
			scale.x *= -1
			flip = value


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	
func damage(isSour : bool):
	if isSour:
		return randi_range(damMin, damMax-damSour)
	else:
		return randi_range(damMin, damMax)

func getSour():
	var sour = get_node("sourSpot")
	return sour

func _ready():
	coyoteTimer = Timer.new()
	coyoteTimer.wait_time = 0.15
	coyoteTimer.connect("timeout", Callable(self, "coyoteTimeout"))
	add_child(coyoteTimer)

func coyoteTimeout() -> void:
	canJump = false;
	coyoteTimer.stop()

func _process(_delta):
	if Input.is_action_just_pressed("die"):
		global_position = Vector2(0,-60)

func _physics_process(delta):
	if not is_on_floor():
		if coyoteTimer.is_stopped() and canJump:
			coyoteTimer.start();
		velocity.y += (gravity * delta)*timescale
	else:
		additionalJumps = 1;
		coyoteTimer.stop()
		canJump = true
	
	#rotate arm towards mouse.y
	var mouse : Vector2 = get_global_mouse_position()
	var dist = mouse.distance_squared_to(global_position)
	if flip:
		mouse.x = -sqrt(dist)
	else:
		mouse.x = sqrt(dist)
	arm.look_at(mouse)
	arm.rotation_degrees = clamp(arm.rotation_degrees, -60, 60)
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if canJump or additionalJumps > 0:
			if additionalJumps > 0 and not canJump:
				additionalJumps -= 1
			velocity.y = JUMP_VELOCITY
			canJump = false
	
	# Handle attack.
	if Input.is_action_just_pressed("n_attack"):
		slashCounter+=1
		attackAnimator.play("slash"+str(slashint))
		slashint += 1
		if slashint == 4:
			slashint = 1
		attackTimer.start()
	if Input.is_action_just_pressed("s_attack"):
		slashCounter+=1
		print("atk - str")
	 	
	if Input.is_action_just_pressed("left"):
		flip = true
	if Input.is_action_just_pressed("right"):
		flip = false
	
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = (direction * SPEED)*timescale
	else:
		velocity.x = (move_toward(velocity.x, 0, SPEED))*timescale

	move_and_slide()


func _on_attack_reset_timeout():
	if slashint == 2:
		attackAnimator.play("reset1")
	elif slashint == 1:
		attackAnimator.play("reset3")
	slashint = 1
