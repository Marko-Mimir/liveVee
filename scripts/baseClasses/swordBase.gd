extends Sprite2D
class_name SwordBase

var handle
var shoulder : Marker2D;

@export var flipOffset : int

func init() -> void:
	player.attack_input.connect(attackInput)
	handle = get_node("./handle")
	

func attackInput(isStrong : bool) -> void:
	print(isStrong)

func get_handle() -> Marker2D:
	return handle

func flip(value : bool) -> void:
	if value:
		offset.x -= flipOffset
	else:
		offset.x += flipOffset
	flip_h = value
