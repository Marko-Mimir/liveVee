extends equipable

var s : String = ""

#this is a class from the superclass, im overwriting it
func onReady() -> void:
	usageDirection.connect(self._onUsage)

func process() -> void:
	if !held : return
	if isAttacking : return
	if Input.is_action_pressed("throw") and arm.isSelected:
		dontAttack = true
		if Input.is_action_just_pressed(arm.action):
			#throw
			dontAttack = false
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
		dontAttack = false
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

func _onUsage(use : equipableUsage):
	if !use: print("Null"); return;
	if isAttacking: return
	print(use.name)
	isAttacking = true
	
	#set arm to start position
	arm.target.global_position = getShoulderLocal(use.start["pos"])
	arm.hand.rotation_degrees = use.start["deg"]
	await get_tree().create_timer(0.1).timeout
	#where the action happens
	arm.target.global_position = getShoulderLocal(use.end["pos"])
	arm.hand.rotation_degrees = use.end["deg"]
	if use.smear_texture and use.smear_collision:
		player.smear.texture = use.smear_texture
		player.smear.position = use.smear["pos"]
		@warning_ignore("integer_division")
		player.smearArea.position = Vector2(-use.smear_texture.get_width()/2, -use.smear_texture.get_height()/2)
		player.smear.rotation_degrees = use.smear["deg"]
		for col in use.smear_collision:
			var poly = CollisionPolygon2D.new()
			poly.polygon = col
			player.smearArea.add_child(poly)
	player.smear.visible = true
	await get_tree().create_timer(.1).timeout
	
	#cleanup
	for child in player.smearArea.get_children():
		player.smearArea.remove_child(child)
	player.smear.visible = false
	await get_tree().create_timer(.07).timeout
	isAttacking = false
