extends RigidBody2D
class_name LiveNpc


@export var camFocus : Focusable = null;
@export var who : String = "";
@export_file(".json") var json_path;

var diologue : Dictionary
var nextChat = "0"
var option
var isChatting := false:
	set(value):
		if isChatting != value:
			player.manager.unfocus()
			isChatting = value

var lastMessage : Dictionary
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
	interact.action.connect(self.speak)
	chat.ChatFinished.connect(self.continueChat)
	player.chat.optionPicked.connect(self.optionsRecieved)
	liveReady()

func speak():
	if isChatting or camFocus.isFocused:
		if player.debugCheck and chat.emitNext:
			chat.skip()
		return
	player.scene.camera.zoomto(2)
	player.scene.camera.pullFocus(camFocus)
	isChatting = true
	player.head.frame = 0
	continueChat()

func optionsRecieved(pos):
	option = pos

func continueChat():
	lastMessage = {}
	print("REPLACE BODY IN SUPER CLASS")
	normalMessage()

func normalMessage() -> void:
	var nextMsg : Dictionary = diologue[nextChat]
	lastMessage = nextMsg
	if nextMsg.has("response"): #Option messages within a convo cannot have the leave flag as of now
		var obj : ChatBubble = chat.new_message(nextMsg["token"])
		obj.manualKill = true
		chat.emitNext = false
		await obj.finish
		player.chat.do_options(nextMsg["response"])
		await player.chat.optionPicked 
		if !is_instance_valid(obj):
			return
		nextChat = nextMsg["next"][option]
		obj.manualKill = false
		obj.switch()
		continueChat()
	elif nextMsg.has("hFlag"):
		if player.chat.hasFlag(who, nextMsg['hFlag']):
			chat.new_message(nextMsg["token"][0])
		else:
			chat.new_message(nextMsg["token"][1])
			nextChat= nextMsg["next"]
	elif nextMsg.has("item"):
		pass
	else:
		chat.new_message(nextMsg["token"])
		nextChat= nextMsg["next"]
	#Friendship pts
	if nextMsg.has("friendship"):
		print('friend edit')
		collection.editFriendship(who, nextMsg["friendship"])
	#Flag stuff
	if nextMsg.has("gFlag"):
		player.chat.giveFlag(who, nextMsg["gFlag"])
	if nextMsg.has("rFlag"):
		player.chat.removeFlag(who, nextMsg["rFlag"])
	#if it has leave, make sure to zoom out after the message
	if nextMsg.has("leave"):
		chat.emitNext = false 
		await chat.curBubble.finish 
		if not camFocus.isFocused:
			return
		player.scene.camera.zoomto(1)
		player.scene.camera.release()
		isChatting = false


#procs when player leaves the interact radius while theyre chattings
func _process(_delta: float) -> void:
	if !camFocus.isFocused:
		return
	if(interact.isPlayer):
		return
	camFocus.release.emit()
	isChatting = false
	if chat.curBubble:
		chat.curBubble.manualKill = true
		chat.curBubble.kys = true
	if lastMessage.is_empty():
		player.scene.camera.zoomto(1)
		return
	if lastMessage.has("response"):
		player.chat.wipeOptions()
	if lastMessage.has("rude"):
		collection.editFriendship(who, -10)
	nextChat = diologue["convo"][lastMessage["convoId"]]["restart"]
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
	pass
