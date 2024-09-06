extends RigidBody2D

@export var base : Enemy
@export var currentState : states = states.WANDER

enum states {WANDER, SNIFF, CHASE, IDLE, JUMP, FALL}
var elseMount = 0
var floorCast : RayCast2D
var eLeft : RayCast2D
var eRight : RayCast2D
var speed = 100
var giveUpDist = 600
var flip = false
var sniffTimer : Timer
@onready var idleTimer : Timer = get_node("idleTimer")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var fallCast
			
# Called when the node enters the scene tree for the first time.
func _ready():
	floorCast = get_node("floorCast")
	fallCast = get_node("fallCast")
	eLeft = get_node("eyeLeft")
	eRight = get_node("eyeRight")
	base.dead.connect(on_dead)
	base.hurt.connect(on_hurt)
	
	sniffTimer = Timer.new()
	sniffTimer.wait_time = 1
	sniffTimer.timeout.connect(sniffout)
	add_child(sniffTimer)
	
func on_dead():
	print_rich("[color=red][wave]#dead lmao")
	queue_free()

func sniffout():
	speed = 150
	currentState = states.CHASE
	sniffTimer.stop()


func _physics_process(delta):
	var space_state = get_world_2d().direct_space_state
	var velocity : Vector2= Vector2(0,0)
	
	if currentState == states.CHASE:
		idleTimer.stop()
		var query = PhysicsRayQueryParameters2D.create(global_position, base.player.global_position, floorCast.collision_mask)
		var result = space_state.intersect_ray(query)
		if result:
			print("WALL INBETWEEN! LOST PLAYER")
			speed = 100
			currentState = states.WANDER
		
		if base.getPlayerDir():
			if not flip:
				doFlip()
			velocity.x = -1
		else:
			if flip:
				doFlip()
			velocity.x = 1
	
	elif currentState == states.IDLE:
		if idleTimer.is_stopped():
			#ANIMATION HERE
			idleTimer.wait_time=(randf_range(0.01, 1))
			idleTimer.start()
	if currentState == states.FALL:
		if fallCast.is_colliding():
			currentState = states.WANDER
	elif currentState == states.SNIFF:
		idleTimer.stop()
		speed = 25
		if flip:
			velocity.x = -1
		else:
			velocity.x = 1
		if sniffTimer.is_stopped():
			sniffTimer.start()
	
	elif currentState == states.WANDER:
		if not fallCast.is_colliding():
			currentState = states.FALL
			return
		if idleTimer.is_stopped():
			idleTimer.start()
		if not floorCast.is_colliding():
			elseMount +=1
			if elseMount == 2:
				doFlip()
				elseMount = 1
		if flip:
			if eLeft.is_colliding():
				speed = 150
				currentState = states.CHASE
			elif eRight.is_colliding():
				currentState = states.SNIFF
			velocity.x = -1
		else:
			if eLeft.is_colliding():
				currentState = states.SNIFF
			elif eRight.is_colliding():
				speed = 150
				currentState = states.CHASE
			velocity.x = 1
		
	velocity = velocity.normalized() * speed *delta
	move_and_collide(velocity)

func doFlip():
	if flip:
		floorCast.position = floorCast.position + Vector2(80,0)
		eLeft.target_position = Vector2(-150, 0)#LEFT IS SNIFF SIDE
		eRight.target_position = Vector2(500, 0)
		flip = false
	else:
		floorCast.position = floorCast.position + Vector2(-80,0)
		eLeft.target_position = Vector2(-500, 0)
		eRight.target_position = Vector2(150, 0)#RIGHT IS SNIFF SIDE
		flip = true

func idleTimeout():
	if currentState == states.IDLE:
		currentState = states.WANDER
		idleTimer.wait_time = randi_range(3,10)
	else:
		currentState = states.IDLE

func on_hurt():
	print("Youch!")
