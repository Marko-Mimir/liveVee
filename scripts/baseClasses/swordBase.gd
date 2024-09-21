extends Sprite2D
class_name SwordBase

var handle

@export var flipOffset : int

func _ready() -> void:
	player.attack_input.connect(attackInput)
	handle = get_node("./handle")
	print(handle)

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
	print(offset)
