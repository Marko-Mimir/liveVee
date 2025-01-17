extends SwordBase

func _ready() -> void:
	init()
	print(shoulder)

func _process(delta: float) -> void:
	var global = global_position
	var shoulder = shoulder.global_position
	if (shoulder.y < global.y):
		frame = 0
	else:
		frame = 2
