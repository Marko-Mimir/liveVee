extends RigidBody2D
class_name LiveNpc

var interact : AOI;


func _ready() -> void:
	#find children loop
	for child in get_children():
		if child is AOI:
			interact = child
			break
	liveReady()

func liveReady():
	print('test')
