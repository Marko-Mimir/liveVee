extends RigidBody2D
class_name LiveNpc

@export var camFocus : Focusable = null;
@export_file(".json") var json_path;

var diologue : Dictionary

var chat : LiveChat
var interact : AOI;
var blink : Sprite2D;
var btimer : Timer


func _ready() -> void:
	#setup diologue json
	if json_path:
		diologue = util.loadJson(json_path)
	#find children loop
	for child in get_children():
		if child is AOI:
			interact = child
			blink = get_node_or_null((String(interact.sprite.get_path())+"/blink"))
			if blink != null:
				var blink_timer := Timer.new()
				blink_timer.one_shot = false
				blink_timer.wait_time = 1.0
				blink_timer.timeout.connect(doblink)
				add_child(blink_timer)
				blink_timer.start()
				btimer = blink_timer
			else:
				if player.debugCheck:
					print("Npc "+get_script().get_path()+ " has no blink")
		if child is LiveChat:
			chat = child
	liveReady()


func _process(_delta: float) -> void:
	if !camFocus.isFocused:
		return
	if(interact.isPlayer):
		return
	camFocus.release.emit()
	player.scene.camera.zoomto(1)

func doblink():
	if blink.visible:
		blink.visible = false;
		btimer.wait_time = randf_range(1,4)
		btimer.start()
		return
	blink.visible = true
	btimer.wait_time = 0.1
	btimer.start()

func liveReady():
	print('test')
