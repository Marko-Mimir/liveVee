extends HBoxContainer
class_name ChatBubble

signal finish(chat)

var manualKill := false
var label : RichTextLabel
var diologue : String = "ERROR, diologue not changed."
var raw : String
var kys := false

func onReady() -> void:
	label = $Panel/RichTextLabel
	label.text = diologue
	#do typewrite
	label.visible_characters = 0
	typewrite()

func _process(_delta: float) -> void:
	if !kys: return;
	modulate = lerp(modulate, Color.TRANSPARENT, .05)
	if modulate.a <= .005:
		queue_free()

func switch():
	if manualKill:
		return
	await get_tree().create_timer(2).timeout
	kys = true

func skip():
	label.visible_characters = len(raw)+1

func typewrite():
	if label.visible_characters > len(raw):
		finish.emit(self)
		switch()
		return #done
	if label.visible_characters == 0:
		label.visible_characters+=1
		typewrite()
		return
	if str(raw[label.visible_characters-1]) == ",":
		await get_tree().create_timer(.1).timeout
		label.visible_characters += 1
	elif str(raw[label.visible_characters-1]) == ".":
		await get_tree().create_timer(1).timeout
		label.visible_characters += 1
	else:
		await get_tree().create_timer(.03).timeout
		label.visible_characters += 1
	typewrite()
	
