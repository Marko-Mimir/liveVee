extends LiveNpc

func buildHub() -> Dictionary:
	var q := {}
	if player.chat.hasFlag(who, "BadIntro"):
		q.set("10", tr("ENG-HUB-2"))
	if player.inventory.hasItem(1) and player.chat.hasFlag(who, "GoodIntro"):
		player.scene.gamePrint("HAS BP")
		var p
		if player.inventory.getItems(1) >= 2:
			p = tr("ENG-HUB-1:1")
		else: p=tr("ENG-HUB-1:2")
		q.set("9", tr("ENG-HUB-1").format({plural = p}))
	q.set("LEAVE", tr("GEN-LEAVE"))
	return q

func continueChat():
	lastMessage = {}
	if nextChat == "HUB":
		var hub := buildHub()
		chat.new_message("ENG-INTRO-"+str(collection.queryFriendship(who)))
		chat.emitNext = false
		player.chat.do_options(hub.values())
		await player.chat.optionPicked
		if hub.keys()[option] == "LEAVE":
			await player.chat.ChatFinished
			player.scene.camera.zoomto(1)
			player.scene.camera.release()
			isChatting = false
			return
		nextChat = hub.keys()[option]
		player.scene.gamePrint(nextChat)
		await player.chat.ChatFinished
		continueChat()
		return
	if nextChat == "&b":
		player.scene.camera.zoomto(1)
		player.scene.camera.release()
		isChatting = false
		nextChat = "HUB"
		return
	normalMessage()
	#PROBABLY CAN BE PUT INTO NPC BASECLASS (below stuff)
	
