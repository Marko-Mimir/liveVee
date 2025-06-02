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
var collectables : Dictionary

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

func validateCollectable(item : Dictionary) -> bool:
	if !collectables:
		collectables = loadJson("res://resources/collectables.json")
	if collectables[str(item["type"])].has(str(item["id"])):
		return true
	return false

func getCollectableData(item : Dictionary):
	if !collectables:
		collectables = loadJson("res://resources/collectables.json")
	return collectables[str(item["type"])][str(item["id"])]
