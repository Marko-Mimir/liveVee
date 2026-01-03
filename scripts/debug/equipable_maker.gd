extends Node2D
class_name DebugMaker

@export var animation : LiveAnimationPlayer
@export var vbox : VBoxContainer
@export var sprite : Sprite2D
@export var focus : RemoteTransform2D
@export var leftArm : Node2D
@export var leftSkeleton : Skeleton2D
@export var leftFocus : Marker2D
@export var rightArm : Node2D
@export var rightSkeleton : Skeleton2D
@export var rightFocus : Marker2D
@export var focusSprite : DraggableSprite2D
@export var equipableSprite : DraggableSprite2D
@export var dragName : Label
@export var animationList : OptionButton
@export var updatedTime : Label
@export var timeline : HSlider
var currentEquipable : LiveEquipable
var lastDrag : DraggableSprite2D
var animations : Array[String] = []
var dir = DirAccess.open("res://resources/equipables/")
var isPlaying : bool = false
var currentAnimation : String
@export var play : CompressedTexture2D
@export var pause : CompressedTexture2D

func _ready() -> void:
	player.queue_free()
	rightArm.modulate = Color.WHITE
	leftArm.modulate = Color.DIM_GRAY
	if dir:
		wipeBlur()
		$Screenblur.visible = true
		$Screenblur/EquipableSelector.visible = true
		populateEquipment()
	focusSprite.grabbed.connect(self.dragableClicked.bind(focusSprite))
	equipableSprite.grabbed.connect(self.dragableClicked.bind(equipableSprite))
	focusSprite.released.connect(self.dragableDropped.bind(focusSprite))
	equipableSprite.released.connect(self.dragableDropped.bind(equipableSprite))

func populateEquipment() -> void:
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name !="":
		var button : Button = Button.new()
		button.text = file_name
		button.pressed.connect(self.fileSelect.bind(button, file_name))
		vbox.add_child(button)
		file_name=dir.get_next()

func fileSelect(_button : Button, file_name : String):
	$Screenblur.visible = false
	currentEquipable = load("res://resources/equipables/"+file_name)
	print(currentEquipable.name)
	equipableSprite.texture = currentEquipable.sprite
	equipableSprite.hframes = currentEquipable.frames.x
	equipableSprite.vframes = currentEquipable.frames.y
	for x in currentEquipable.animations:
		print(x.name)
		animations.append(x.name)
	for n in vbox.get_children():
		n.queue_free()
	initalizeOptions()

func swapEquip() -> void:
	wipeBlur()
	$Screenblur.visible = true
	$Screenblur/EquipableSelector.visible = true
	populateEquipment()

func flip(toggled_on: bool) -> void:
	if toggled_on:
		sprite.scale.x = -1
	else:
		sprite.scale.x = 1
	#Flip the arm bones
	flipArm(leftSkeleton, leftArm)
	flipArm(rightSkeleton, rightArm)
	#Flip the target position, default is facing RIGHT
	var square = focus.get_parent()
	square.position.x = square.position.x * -1

func flipArm(skeleton : Skeleton2D, arm : Node2D) -> void:
	arm.z_index = arm.z_index*-1
	
	#flip the magnet arroundsies
	var stack : SkeletonModificationStack2D = skeleton.get_modification_stack()
	var mod : SkeletonModification2DFABRIK = stack.get_modification(0)
	var magnet : Vector2 = mod.get_fabrik_joint_magnet_position(1)
	magnet.x = magnet.x*-1
	mod.set_fabrik_joint_magnet_position(1, magnet)
	stack.set_modification(0, mod)
	skeleton.set_modification_stack(stack)

func dragableClicked(dragable : DraggableSprite2D) -> void:
	$Inspector.visible = true
	dragName.text = dragable.name
	if dragable.name == "equip":
		dragName.text = currentEquipable.name
	lastDrag = dragable
	if dragable.hframes == 1:
		$Inspector/SpinBox.visible = false
		$Inspector/Frame.visible = false
	else:
		$Inspector/SpinBox.visible = true
		$Inspector/Frame.visible = true
	$Inspector/SpinBox.max_value = dragable.hframes-1
	$Inspector/SpinBox.value = dragable.frame

func dragableDropped(dragable : DraggableSprite2D) -> void:
	if getCurrentAnimationName() in ["-NO ANIMATIONS-", "Add New Animation"]:
		return
	var anim = currentEquipable.animations[findAnimation(getCurrentAnimationName())]
	animation.addKeyframe(anim, dragable.name, getCurrentTime(), dragable.position)

func swap_hand(_toggled_on: bool) -> void:
	if focus.remote_path.get_name(3) == "rightFocus":
		focus.remote_path = leftFocus.get_path();
		rightFocus.position = Vector2(50, -10)
		leftArm.modulate = Color.WHITE
		rightArm.modulate = Color.DIM_GRAY
	else:
		focus.remote_path = rightFocus.get_path();
		leftFocus.position = Vector2(-50,-10)
		rightArm.modulate = Color.WHITE
		leftArm.modulate = Color.DIM_GRAY

func change_dragable_transparency(value: float) -> void:
	lastDrag.modulate.a = value

func wipeBlur() -> void:
	$Screenblur.visible = false
	for n in $Screenblur.get_children():
		n.visible = false
	$Screenblur/Square.visible = true

func createAnimation() -> void:
	wipeBlur()
	$Screenblur/NewAnimation/LineEdit.text = ""
	$Screenblur.visible = true
	$Screenblur/NewAnimation.visible = true
	$Screenblur/NewAnimation/LineEdit.grab_focus()
	await $Screenblur/NewAnimation/LineEdit.text_submitted
	$Screenblur.visible = false
	animations.append($Screenblur/NewAnimation/LineEdit.text)
	var anim = LiveAnimation.new()
	anim.name = ($Screenblur/NewAnimation/LineEdit.text)
	anim.length = 1.0
	currentEquipable.animations.append(anim)
	initalizeOptions($Screenblur/NewAnimation/LineEdit.text)
	animation.addKeyframe(anim, "focus", 0.0, focusSprite.position)
	animation.addKeyframe(anim, "equip", 0.0, equipableSprite.position)
	animation.addKeyframe(anim, "equip:frame", 0.0, 0)

func save():
	var r = ResourceSaver.save(currentEquipable, currentEquipable.resource_path)
	if r == OK:
		print("Success")

func initalizeOptions(wanted : String = ""):
	animationList.clear()
	if animations == []:
		animationList.add_item("-NO ANIMATIONS-", 0)
		animationList.set_item_disabled(0, true)
		animationList.add_item("Add New Animation")
		selectAnimation(0)
		return
	var id = 0
	for anim in animations:
		animationList.add_item(anim, id)
		if anim == wanted:
			selectAnimation(id)
		id+=1
	animationList.add_item("Add New Animation")
	if wanted == "":
		selectAnimation(0)

func selectAnimation(index: int) -> void:
	var anim : String = animationList.get_item_text(index)
	animationList.select(index)
	if anim == "Add New Animation":
		createAnimation()
	elif anim == "-NO ANIMATIONS-":
		return
	else:
		currentAnimation = anim
		var cur = currentEquipable.animations[findAnimation(anim)]
		$timeline/LineEdit.text = str(cur.length)
		timeline.value = 0
		changeAnimationTime(str(cur.length))
		animation.setActorsAtTime(cur, 0.0)
		animation.initPlay(cur, 0.0)

func getCurrentAnimationName() -> String:
	return animationList.get_item_text(animationList.selected)

func getCurrentAnimation() -> LiveAnimation:
	return currentEquipable.animations[findAnimation(getCurrentAnimationName())]

func deleteConfirm() -> void:
	if getCurrentAnimationName() == "-NO ANIMATIONS-":
		return
	wipeBlur()
	$Screenblur/DeleteAnimation/confirm.text = "This wil delete animation ("+getCurrentAnimationName()+")"
	$Screenblur/DeleteAnimation.visible = true
	$Screenblur.visible = true

func findAnimation(find : String) -> int:
	for x in len(currentEquipable.animations):
		if currentEquipable.animations[x].name == find:
			return x
	push_error("Bad animation name.")
	return -1

func actuallyDelete() -> void:
	currentEquipable.animations.pop_at(findAnimation(getCurrentAnimationName()))
	animations.erase(getCurrentAnimationName())
	$Screenblur.visible = false
	initalizeOptions()

func renameAnimation() -> void:
	wipeBlur()
	$Screenblur/RenameAnimation/LineEdit.text = getCurrentAnimationName()
	var old = getCurrentAnimationName()
	$Screenblur/RenameAnimation.visible = true
	$Screenblur.visible = true
	$Screenblur/RenameAnimation/LineEdit.grab_focus()
	$Screenblur/RenameAnimation/LineEdit.caret_column = $Screenblur/RenameAnimation/LineEdit.text.length()
	await $Screenblur/RenameAnimation/LineEdit.text_submitted
	$Screenblur.visible = false
	currentEquipable.animations[findAnimation(old)].name = $Screenblur/RenameAnimation/LineEdit.text
	animations[animations.find(old)] = $Screenblur/RenameAnimation/LineEdit.text
	initalizeOptions($Screenblur/RenameAnimation/LineEdit.text)

func moveTimeline(value: float) -> void:
	updatedTime.text = str(value)
	animation.setActorsAtTime(getCurrentAnimation(), value)
	animation.internalTime = value

func _process(_delta: float) -> void:
	if animation.playing and animation.playAnimation:
		updatedTime.text = str(animation.internalTime)
		timeline.value = animation.internalTime 

func changeAnimationTime(new_text: String) -> void:
	get_viewport().gui_release_focus()
	currentEquipable.animations[findAnimation(currentAnimation)].length = new_text.to_float()
	timeline.max_value = new_text.to_float()
	timeline.tick_count = int(timeline.max_value*10)+1

func getCurrentTime() -> float:
	return float(updatedTime.text)

func playPause() -> void:
	animation.playpause()
	if isPlaying:
		isPlaying = false
		$"timeline/Button".icon = play
	else:
		isPlaying = true
		$"timeline/Button".icon = pause

func changeFrame(value: float) -> void:
	lastDrag.frame = value
	animation.addKeyframe(getCurrentAnimation(), lastDrag.name+":frame", getCurrentTime(), value)
