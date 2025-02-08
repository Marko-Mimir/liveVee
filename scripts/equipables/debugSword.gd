extends equipable

var s : String = ""

#this is a class from the superclass, im overwriting it
func onReady() -> void:
	pass

func process() -> void:
	match s:
		"wake":
			var vec = arm.target.get_global_mouse_position()
			arm.target.global_position.x = vec.x
			var deg = states[s].rotation
			if arm.isFlip:
				deg = flipDeg(deg)
			arm.hand.rotation_degrees = deg
		"rest":
			var deg = states[s].rotation
			if arm.isFlip:
				deg = flipDeg(deg)
			arm.hand.rotation_degrees = deg

func getShoulderLocal(vec : Vector2) -> Vector2:
	arm.shoulder.position = vec
	return arm.shoulder.global_position

func flipDeg(deg : int)-> float:
	var isNeg : float = deg/abs(deg)
	var flip = 180-abs(deg)
	return flip*isNeg

func select(val : bool) -> void:
	if val:
		s = "wake"
		arm.target.global_position = getShoulderLocal(states[s].position)
	else:
		s = "rest"
		arm.target.global_position = getShoulderLocal(states[s].position)
		arm.hand.rotation_degrees = states[s].rotation
