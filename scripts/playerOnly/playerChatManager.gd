extends LiveChat
class_name PlayerChat

signal optionPicked(option)
@export var bubble : PackedScene
var lastOptions := []
var flags : Dictionary = {}


func _ready() -> void:
	size = Vector2(280,240)
	position = Vector2(0,0)
	var playerCollider : CollisionShape2D = player.get_node("player")
	var offset : Vector2 = playerCollider.shape.size
	@warning_ignore("integer_division")
	position.y -= offset.y/2
	position.x -= size.x/4
	position.y -= size.y/2+5

func new_message(key) -> Object:
	#this has taken years off my life I really hope I dont have to rewrite this I'll have to kms instead lmfao
	#if you're reding this pls dont judge me i wrote this on hopes and dreams alone.
	#a lone dev with documention and an idea against the world.
	var chatbubble : ChatBubble = packedScene.instantiate()
	
	#split this into a seprate function so i could reuse it for PlayerChatManager lol
	var final = wrapText(key)
	
	var r = util.get_raw("&", tr(key))
	chatbubble.raw = r["raw"]
	final = "[center]"+final+"[/center]"
	chatbubble.diologue = util.translateAltColorCodes("&", final)
	add_child(chatbubble)
	chatbubble.finish.connect(onFinish)
	chatbubble.onReady()
	return chatbubble

#get an array of options, return position of the option that got selected. 
#connect to ButtonHit to get response.
func do_options(options : Array):
	lastOptions = options
	var itter = 0
	for option in options:
		var optionBubble : OptionBubble = bubble.instantiate()
		#TODO: add localization support
		var final = wrapText(option)
		final = "[center]"+final+"[/center]"
		optionBubble.diologue = util.translateAltColorCodes("&", final)
		optionBubble.pos = itter
		add_child(optionBubble)
		optionBubble.hit.connect(buttonHit)
		optionBubble.onReady()
		itter+=1

func wipeOptions():
	for child in get_children():
		child.kys = true

func giveFlag(obj : String, flag : String):
	player.scene.gamePrint(flag)
	flags.get_or_add(obj, [])
	var f = flags[obj]
	if f == null:
		f = []
	f.append(flag)
	flags.set(obj, f)
	print(flags)

func hasFlag(obj : String, flag:String)->bool:
	if !flags.has(obj):
		return false
	if !flags[obj].has(flag):
		return false
	return true

func buttonHit(pos):
	wipeOptions()
	await get_tree().create_timer(.5).timeout
	new_message(lastOptions[pos])
	optionPicked.emit(pos)
