extends equipable

var s : String = ""

#this is a class from the superclass, im overwriting it
func onReady() -> void:
	usageDirection.connect(self._onUsage)

func process() -> void:
	if !held : return
	if Input.is_action_pressed("throw") and arm.isSelected:
		if Input.is_action_just_pressed(arm.action):
			#throw
			var tar = arm.target.get_local_mouse_position()
			var v : Vector2 = -(arm.target.position - tar).normalized()
			v = v*450
			arm.dequip(v)
			global_rotation = v.angle()
			return
		
		arm.queue_redraw()
		var deg = states["throw"].rotation
		var vec = states["throw"].position
		if arm.isFlip:
			deg = flipDeg(deg)
			vec.x = -vec.x
		arm.target.global_position = getShoulderLocal(vec)
		arm.hand.rotation_degrees = deg
		return
	if Input.is_action_just_released("throw"):
		select(arm.isSelected)
		arm.queue_redraw()
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

func select(val : bool) -> void:
	if val:
		s = "wake"
		arm.target.global_position = getShoulderLocal(states[s].position)
	else:
		s = "rest"
		arm.queue_redraw()
		arm.target.global_position = getShoulderLocal(states[s].position)
		arm.hand.rotation_degrees = states[s].rotation

func _onUsage(dir : equipableUsage):
	return
