extends LiveNpc

var friendship = 0
var nextChat = "0"
var currentConvo := "-1"
var leftMidConvo := false
var option = -1
var avaliableConvos := ["BP"]
var isChatting := false


func liveReady() -> void:
	interact.action.connect(self.speak)
	chat.ChatFinished.connect(self.continueChat)
	player.chat.optionPicked.connect(self.optionsRecieved)

func speak():
	if isChatting or camFocus.isFocused:
		if player.debugCheck and chat.emitNext:
			chat.skip()
		return
	player.scene.camera.zoomto(2)
	player.scene.camera.pullFocus(camFocus)
	isChatting = true
	
	continueChat()

func optionsRecieved(pos):
	option = pos

func buildHub():
	var q := {}
	for convo in avaliableConvos:
		if convo == "BP":
			var p
			if len(player.inventory.InvBlueprints) >= 2:
				p = tr("ENG-HUB-1:1")
			else: p=tr("ENG-HUB-1:2")
			q.set("bp", tr("ENG-HUB-1").format({plural = p}))
			print(q)

func continueChat():
	if nextChat == "HUB":
		player.scene.gamePrint("Hub doesn't exist as of now lol")
		buildHub()
		return
	var nextMsg : Dictionary = diologue[nextChat]
	#different message types: (option, flagged, seached, or  normal)
	if nextMsg.has("response"): #Option messages within a convo cannot have the leave flag as of now
		var obj : ChatBubble = chat.new_message(nextMsg["token"])
		obj.manualKill = true
		chat.emitNext = false
		await obj.finish
		player.chat.do_options(nextMsg["response"])
		await player.chat.optionPicked
		nextChat = nextMsg["next"][option]
		obj.manualKill = false
		obj.switch()
		continueChat()
	elif nextMsg.has("hFlag"):
		if player.chat.hasFlag("eng", nextMsg['hFlag']):
			chat.new_message(nextMsg["token"][0])
		else:
			
			chat.new_message(nextMsg["token"][1])
			nextChat= nextMsg["next"]
	elif nextMsg.has("item"):
		pass
	else:
		chat.new_message(nextMsg["token"])
		nextChat= nextMsg["next"]
	
	#Flag stuff
	if nextMsg.has("gFlag"):
		player.chat.giveFlag("eng", nextMsg["gFlag"])
	#if it has leave, make sure to zoom out after the message
	if nextMsg.has("leave"):
		chat.emitNext = false
		await chat.ChatFinished
		player.scene.camera.zoomto(1)
		player.scene.camera.release()
		isChatting = false
