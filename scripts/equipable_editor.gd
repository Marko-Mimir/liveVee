extends Node2D

var equip : equipable;
@export var vbox : VBoxContainer
@export var option : OptionButton
@export var edit : TextEdit
@export var tPos : Label
@export var tDeg : Label
var shoulder : Marker2D;
var settings : equipableSettings = null
var hover : bool = false

var state : String = ""
var dir = DirAccess.open("res://objects/equipables")

func _ready() -> void:
	player.queue_free()
	edit.visible = false
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name !="":
			var button : Button = Button.new()
			button.text = file_name
			button.pressed.connect(self.button_press.bind(button))
			vbox.add_child(button)
			
			file_name=dir.get_next()

func button_press(button : Button):
	vbox.get_parent().queue_free()
	var packedEquip = load("res://objects/equipables/"+button.text)
	var item = packedEquip.instantiate()
	add_child(item)
	equip = item
	
	equip.held = true
	shoulder = get_node("shoulder/item")
	equip.z_index = 7
	equip.rotation_degrees = 0
	equip.reparent(shoulder)
	equip.position = Vector2(equip.offset,0)
	settings = equip.settings
	
	resetOptions()

func _process(delta: float) -> void:
	if !hover : return
	if equip == null: return
	if state == "": return
	if Input.is_action_just_pressed("leftMouse"):
		shoulder.global_position = equip.get_global_mouse_position()
		var x = getState(state)
		x.position = shoulder.position
		tPos.text = str(shoulder.position)
	if Input.is_action_pressed("rightMouse"):
		var vec = get_global_mouse_position() - shoulder.global_position
		shoulder.rotation = vec.angle()
		var x = getState(state)
		x.rotation = shoulder.rotation_degrees
		tDeg.text = str(shoulder.rotation_degrees)+"°"

func getState(text : String)->equipableState:
	for x in settings.states:
		if x.name == text:
			return x
	return null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		edit.visible = false
		var y := equipableState.new()
		y.name = edit.text
		edit.text = ""
		settings.states.append(y)
		var x = resetOptions(y.name)
		option.select(x)
		_on_item_selected(x)

func resetOptions(check : String = "") -> int:
	option.clear()
	var r = 0
	var id = 0
	for x in settings.states:
		if x.name == check:
			r = id
		option.add_item(x.name, id)
		id+=1
	option.add_item("+ Add New Item", id)
	option.selected = -1
	return r;

func _on_item_selected(index: int) -> void:
	var text = option.get_item_text(index)
	if text == "+ Add New Item":
		edit.visible = true
		edit.grab_focus()
		state = ""
	for x in settings.states:
		if text == x.name:
			self.state = text
			shoulder.position = x.position
			shoulder.rotation_degrees = x.rotation
			tPos.text = str(x.position)
			tDeg.text = str(x.rotation)


func save() -> void:
	ResourceSaver.save(settings, "res://resources/equipables/"+equip.name+".tres")


func leave() -> void:
	hover = false

func join() -> void:
	hover = true
