extends LiveNpc

func liveReady() -> void:
	interact.action.connect(self.meow)
	print('ready')

func meow():
	player.scene.gamePrint("testing here")
