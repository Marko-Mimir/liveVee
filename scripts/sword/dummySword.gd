extends SwordBase

var up = false;
var hitcount = 1;
var combozone = false;
var combohits = 0;
@onready var strike : AnimationPlayer = get_node("strike")
@onready var combo : Timer = get_node("hitcombo")

func _ready() -> void:
	init()
	combo.timeout.connect(timeout)
	print(shoulder)

func _process(delta: float) -> void:
	var global = global_position
	var shoulder = shoulder.global_position
	
	
	#combo zone exclusion, anything that should happen all the time should go before this line of code.
	if(combozone):	return;
	if (shoulder.y+14 < global.y):
		frame = 0
		up = false
	else:
		frame = 2
		up = true

func attackInput(isStrong : bool) -> void:
	combozone = true
	combo.start()
	
	handle.position=Vector2(0,0)
	
	if hitcount == 3:
		strike.play("thrust")
		hitcount=0
	elif up:
		strike.play("downslice")
		up=false
	else:
		strike.play("upslice")
		up=true
	hitcount+=1
	print(hitcount)
	combohits+=1

func timeout() -> void:
	print_rich("[color=red][wave]Combo dead. ["+str(combohits)+"] Hits.")
	combozone=false
	combohits=0
