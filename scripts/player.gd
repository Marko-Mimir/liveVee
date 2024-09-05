extends CharacterBody2D
class_name Character

@export var character : Node2D
const SPEED = 500.0
const JUMP_VELOCITY = -400.0
var canJump = false;
var coyoteTimer : Timer;
var additionalJumps : int = 1
var damage = 15
var slashint = 1
var flip: bool = false:
	set(value):
		if (flip != value):
			scale.x *= -1
			flip = value


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

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
		velocity.y += gravity * delta
	else:
		additionalJumps = 1;
		coyoteTimer.stop()
		canJump = true
	
	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if canJump or additionalJumps > 0:
			if additionalJumps > 0 and not canJump:
				additionalJumps -= 1
			velocity.y = JUMP_VELOCITY
			canJump = false
	
	# Handle attack.
	if Input.is_action_just_pressed("n_attack"):
		$swordAnimator.play("slash"+str(slashint))
		slashint += 1
		if slashint == 4:
			slashint = 1
	if Input.is_action_just_pressed("s_attack"):
		print("atk - str")
	 	
	if Input.is_action_just_pressed("left"):
		flip = true
	if Input.is_action_just_pressed("right"):
		flip = false
	
	var direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
