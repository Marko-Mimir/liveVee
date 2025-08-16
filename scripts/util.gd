extends Node

var TextColors : Dictionary[String, String] = {
	"0" : "[color=black]",
	"1" : "[color=dark_blue]",
	"2" : "[color=dark_green]",
	"3" : "[color=dark_cyan]",
	"4" : "[color=dark_red]",
	"5" : "[color=web_purple]",
	"6" : "[color=goldenrod]",
	"7" : "[color=dark_gray]",
	"8" : "[color=dim_gray]",
	"9" : "[color=blue]",
	"a" : "[color=lime_green]",
	"b" : "[color=aqua]",
	"c" : "[color=firebrick]",
	"d" : "[color=magenta]",
	"e" : "[color=yellow]",
	"f" : "[color=white]"
}
var items : Dictionary

var letterCheck : RegEx
var countWords : RegEx

var dummyTexture := "res://sprites/collectable/dummycollect.png"
var sceneTransition := "res://objects/UI/transition.tscn"

func _ready() -> void:
	countWords = RegEx.new()
	countWords.compile("\\S+")
	letterCheck = RegEx.new()
	letterCheck.compile("[a-zA-Z]")

func get_raw(altColorCode : String, translateText : String):
	var brokenString : PackedStringArray = translateText.split(altColorCode)
	
	var patched : Array[String];
	var rawText : String = brokenString.get(0)
	brokenString.remove_at(0)
	patched.append(rawText)
	for line in brokenString:
		patched.append("&"+line[0])
		var r = line.erase(0)
		patched.append(r)
		rawText+=r
	
	return {"raw":rawText, "patch":patched}

func wordCount(str : String):
	return countWords.search_all(str).size()

func isLetter(str: String):
	return letterCheck.search(str)

func playerRight(obj : Node2D):
	if player.position.x >= obj.position.x:
		return true
	return false

func switchScene(scene : PackedScene):
	var cur = player.scene
	var new = scene.instantiate()
	var trans = load(sceneTransition).instantiate()
	ui.add_ui(trans)
	await trans.half
	cur.queue_free()
	get_tree().root.add_child(new)

func translateAltColorCodes(altColorCode : String, textToTranslate : String):
	var brokenString : PackedStringArray = textToTranslate.split(altColorCode)
	var ends = ""
	
	var coloredText : String = brokenString.get(0)
	brokenString.remove_at(0)
	for line in brokenString:
		var code = line[0]
		if code == "r":
			coloredText += ends + line.erase(0)
		elif code == "w":
			coloredText += "[wave]" + line.erase(0)
			ends = "[/wave]"
		else:
			coloredText += TextColors[code] + line.erase(0)
			ends += "[/color]"
	
	return coloredText

func confirm(question = "UI-CONFIRM", yes = "UI-YES", no = "UI-NO") -> LiveConfirmation:
	var conf : LiveConfirmation = load("res://objects/UI/confirmDiologue.tscn").instantiate()
	ui.add_ui(conf)
	conf.init(question, yes, no)
	return conf

func loadJson(path : String)-> Dictionary:
	var json_as_text = FileAccess.get_file_as_string(path)
	if json_as_text == "":
		player.scene.gamePrint("ERROR WITH LOADJSON PATH ["+path+"] RETURNING {}")
		return {}
	var json = JSON.parse_string(json_as_text)
	if json is Dictionary:
		return json;
	player.scene.gamePrint("ERROR WITH JSON WITH PATH ["+path+"] RETURNING {} EXPECTED [Dictionary] GOT ["+type_string(typeof(json))+"]")
	return {}

func isNeg(num : int)-> bool:
	if abs(num) == num:
		return false
	return true

func getItem(id : int)-> Dictionary:
	if items.is_empty():
		items = loadJson("res://resources/json/items.json");
	if !items.keys().has(str(id)):
		player.scene.gamePrint("&4Error with getting item data. Invalid ID. ["+str(id)+"]")
		return {}
	return items.get(str(id))
