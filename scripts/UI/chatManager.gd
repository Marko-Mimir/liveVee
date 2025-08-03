extends VBoxContainer
class_name LiveChat

@export var talkingSprite : Sprite2D;
@export var packedScene : PackedScene;
@export var font : Font;

var curBubble : ChatBubble = null
var emitNext := true
signal ChatFinished()

func _ready() -> void:
	size = Vector2(280,240)
	position = Vector2(0,0)
	@warning_ignore("integer_division")
	position.y -= talkingSprite.texture.get_height()/2
	position.x -= size.x/4
	position.y -= size.y/2+5

#It works :D 7/25/2025
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
	curBubble = chatbubble
	return chatbubble

func wrapText(key)->String:
	var msg : String = tr(key)
	var raw : String = util.get_raw("&", tr(key))["raw"];
	
	var chatsize = font.get_string_size(raw)
	chatsize.x += 15 
	var final := ""
	#autowrap the text :)
	if chatsize.x> size.x:
		@warning_ignore("integer_division")
		var csize = int(str(chatsize.x/size.x)[0])
		@warning_ignore("integer_division")
		var seperation = round(len(raw)/(csize+1))
		var lines := []
		for x in range(csize+1):
			lines.append(raw.left(seperation))
			raw = raw.erase(0, seperation)
		var leftovers = ""
		for line : String in lines:
			if leftovers != "":
				line = leftovers+line
				var howMuch = len(line)-seperation
				if howMuch == abs(howMuch):
					leftovers = line.right(howMuch)
					line = line.left(seperation)
			if line.ends_with(" "):
				line = line.rstrip(" ")
				final += line+"\n"
			else:
				var pos = -1
				var itter = 1
				while pos == -1:
					if line.right(itter).begins_with(" "):
						pos = itter
						break
					itter += 1
					if itter > len(line):
						pos = -2
				if pos != -2:
					leftovers = line.right(pos-1)+leftovers
					line = line.left(len(line)-pos)
				final += line+"\n"
		
		var _doubleLeft = ""
		if leftovers != "":
			if len(leftovers) < seperation:
				final += leftovers
			else:
				var howMuch = len(leftovers)-seperation
				if howMuch == abs(howMuch):
					_doubleLeft = leftovers.right(howMuch)
					leftovers = leftovers.left(seperation)
	else:
		#if text does not need autowrap just simply ignore like ~70 lines of code lmfao
		final = msg
	

	var r = util.get_raw("&", msg)
	
	#Re-introduce color codes if some were stripped off.
	if len(r["patch"]) != 1:
		var ammountOfCodes = (len(r["patch"])-1)/2
		var patch : Array[String] = r["patch"]
		var pointer := 0
		var t = final
		final = ""
		while ammountOfCodes > 0:
			var wc = util.wordCount(patch[pointer])
			var wcounter = 0
			var itter = 0
			var bk = true #break
			while wcounter != wc+1:
				var res = util.isLetter(t[itter])
				if res == null:
					bk = true
				if bk and res:
					wcounter +=1
					bk = false
				itter+=1
			final += t.left(itter-1)+patch[pointer+1]
			t = t.erase(0, itter-1)
			pointer +=2
			ammountOfCodes-=1
		final+=t
	return final

func skip():
	if curBubble == null: return;
	curBubble.skip()

func onFinish(_chat : ChatBubble):
	if emitNext == false:
		emitNext = true
		return
	ChatFinished.emit()
