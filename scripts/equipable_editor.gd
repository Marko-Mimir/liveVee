extends Node2D

var equip : equipable;
@export_category("menuStuff")
@export var usage : Control
@export var states : Control
@export var flipBox : Sprite2D
@export_subgroup("States")
@export var vbox : VBoxContainer
@export var sOpt : OptionButton
@export var edit : TextEdit
@export var tPos : Label
@export var tDeg : Label
@export_subgroup("Usage")
@export var uOpt : OptionButton
@export var buttons : GridContainer
@export var arrows : Node2D
@export var start : Button
@export var end : Button
@export var smear : Button

var angles

enum directions {UL, U, UR, L, R, DL, D, DR}

var shoulder : Marker2D;
var settings : equipableSettings = null
var hover : bool = false
var selected : String = ""
var dir = DirAccess.open("res://objects/equipables")
var active_pos
var active_sprite
var active_deg
var loop

var flip = false

signal enterHit

func _ready() -> void:
	loop = [start,end,smear]
	player.queue_free()
	edit.get_parent().visible = false
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name !="":
			var button : Button = Button.new()
			button.text = file_name
			button.pressed.connect(self.fileSelect.bind(button))
			vbox.add_child(button)
			file_name=dir.get_next()
	for x in buttons.get_children():
		if x is Button:
			x.pressed.connect(self.direction_button.bind(x))
	for x in loop:
		x.pressed.connect(self._usage_edit.bind(x))

func fileSelect(_button : Button):
	vbox.get_parent().queue_free()
	var packedEquip = load("res://objects/equipables/"+_button.text)
	print(packedEquip)
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
	
	var shou1 = start.get_child(2)
	var shou2 = end.get_child(2)
	shou1.global_position = Vector2(0,0) 
	shou1.get_child(0).texture = equip.sprite.texture
	shou1.get_child(0).position = Vector2(equip.offset,0)
	shou2.get_child(0).texture = equip.sprite.texture
	shou2.global_position = Vector2(0,0)
	shou2.get_child(0).position = Vector2(equip.offset,0)
	
	reset()

func direction_button(button : Button):
	if selected == "": return;
	var y = button.name.to_int()
	var u = getUsage(selected)
	var a = arrows.get_children()
	for x in len(u.directions):
		if u.directions[x] == y:
			u.directions.pop_at(x)
			button.modulate = Color.WHITE
			a[y].visible = false
			return
	u.directions.append(y)
	button.modulate = Color.DIM_GRAY
	a[y].visible = true

func _process(_delta: float) -> void:
	if !hover : return
	if equip == null: return
	if selected == "": return
	if usage.visible: 
		if !active_deg: return;
		if Input.is_action_just_pressed("leftMouse"):
			active_sprite.global_position = equip.get_global_mouse_position()
			var x = getUsage(selected)
			x.get(active_deg.get_parent().name)["pos"] = snapped(to_local(active_sprite.global_position), Vector2(00.1, 00.1))
			active_pos.text = "Pos: " + str(snapped(to_local(active_sprite.global_position), Vector2(00.1, 00.1)))
		if Input.is_action_pressed("rightMouse"):
			var vec = get_global_mouse_position() - shoulder.global_position
			active_sprite.rotation = vec.angle()
			var x = getUsage(selected)
			x.get(active_deg.get_parent().name)["deg"] = snapped(active_sprite.rotation_degrees, 00.1)
			active_deg.text = "Deg: "+str(snapped(active_sprite.rotation_degrees, 00.1))+"°"
		return
	if Input.is_action_just_pressed("leftMouse"):
		shoulder.global_position = equip.get_global_mouse_position()
		var x = getState(selected)
		x.position = snapped(shoulder.position, Vector2(00.1, 00.1))
		tPos.text = str(snapped(shoulder.position, Vector2(00.1, 00.1)))
	if Input.is_action_pressed("rightMouse"):
		var vec = get_global_mouse_position() - shoulder.global_position
		shoulder.rotation = vec.angle()
		var x = getState(selected)
		x.rotation = snapped(shoulder.rotation_degrees, 00.1)
		tDeg.text = str(snapped(shoulder.rotation_degrees, 00.1))+"°"

func getState(text : String)->equipableState:
	for x in settings.states:
		if x.name == text:
			return x
	return null

func getUsage(text : String)->equipableUsage:
	for x in settings.usages:
		if x.name == text:
			return x
	return null

func reset():
	sOpt.clear()
	uOpt.clear()
	var id = 0
	for x in settings.states:
		sOpt.add_item(x.name, id)
		id=id+1
	sOpt.add_item("+ Add New Item", id)
	sOpt.selected = -1
	id = 0
	for x in settings.usages:
		uOpt.add_item(x.name, id)
		id=id+1
	uOpt.add_item("+ Add New Item", id)
	uOpt.selected = -1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter"):
		enterHit.emit()

func addNew(isUsage):
	edit.get_parent().visible = true
	edit.grab_focus()
	await enterHit
	var text = edit.text
	edit.text = ""
	if isUsage:
		var u:= equipableUsage.new()
		u.name = text
		u.end = {"pos" : Vector2(0,0), "deg":0.01}
		u.start = {"pos" : Vector2(0,0), "deg":0.01}
		u.smear = {"pos" : Vector2(0,0), "deg":0.01}
		settings.usages.append(u)
		reset()
		var t = getOption(text, isUsage)
		uOpt.select(t)
		_opt_select(t)
	else:
		var s:= equipableState.new()
		s.name = text
		settings.states.append(s)
		reset()
		getOption(text, isUsage)
		var t=getOption(text, isUsage)
		sOpt.select(t)
		_state_select(t)
	edit.get_parent().visible = false

func getOption(check:String, isUsage)->int:
	var opt : OptionButton
	if isUsage : 
		opt = uOpt
	else: 
		opt = sOpt
	for x in opt.item_count:
		if opt.get_item_text(x) == check:
			return x
	return -1

func select(index: int, isUsage : bool) -> void:
	var text := ""
	if isUsage: text = uOpt.get_item_text(index)
	else: text = sOpt.get_item_text(index)
	if text == "+ Add New Item":
		addNew(isUsage)
		return
	if isUsage:
		for x in settings.usages:
			if text == x.name:
				selected = text
				var b = buttons.get_children()
				b.pop_at(4)
				var a = arrows.get_children()
				print(x)
				#if x.smear_texture: 
				smear.disabled = false
				smear.get_child(2).texture = x.smear_texture
				smear.get_child(2).global_position = Vector2(0,0)
				#else: 
				#	smear.disabled = true
					
				var l = [x.start, x.end, x.smear]
				for y in len(l):
					if l[y] == null: return;
					loop[y].get_child(0).text = "Pos: "+str(l[y]["pos"])
					loop[y].get_child(1).text = "Deg: "+str(l[y]["deg"])
					loop[y].get_child(2).global_position = (l[y]["pos"])
					loop[y].get_child(2).rotation_degrees = l[y]["deg"]
				for i in len(b):
					b[i].modulate = Color.WHITE
					a[i].visible = false
				for y in x.directions:
					b[y].modulate = Color.DIM_GRAY
					a[y].visible = true
		return
	for x in settings.states:
		if text == x.name:
			selected = text
			shoulder.position = x.position
			shoulder.rotation_degrees = x.rotation
			tPos.text = str(x.position)
			tDeg.text = str(x.rotation)

func _opt_select(index: int) -> void:
	select(index, true)

func _state_select(index: int) -> void:
	select(index, false)

func save() -> void:
	if !equip: return
	var r = ResourceSaver.save(settings, "res://resources/equipables/"+equip.name+".tres")
	if r == OK:
		$Label2.visible = true
		await get_tree().create_timer(.5).timeout
		$Label2.visible = false

func leave() -> void:
	hover = false

func join() -> void:
	hover = true

func _usage_edit(bttn : Button):
	if selected == "": return;
	start.z_index = 10
	end.z_index = 10
	smear.z_index = 10
	bttn.z_index +=10
	active_pos = bttn.get_child(0)
	active_deg = bttn.get_child(1)
	active_sprite = bttn.get_child(2)

func _inspectorSwitch() -> void:
	if !equip:	return;
	usage.visible = !usage.visible
	states.visible = !states.visible
	flipBox.flip_h = !flipBox.flip_h
	selected = ""
	uOpt.select(-1)
	sOpt.select(-1)
	flip = !flip
	equip.visible = !equip.visible
