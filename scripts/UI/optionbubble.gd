extends HBoxContainer
class_name OptionBubble

signal hit(position)

var pos = 0
var label : RichTextLabel
var diologue : String = "ERROR, diologue not changed."
var hover := false
var kys := false

func onReady() -> void:
	modulate = Color.TRANSPARENT
	label = $Panel/RichTextLabel
	label.text = diologue

func _process(_delta: float) -> void:
	if !kys: 
		if hover:
			modulate = lerp(modulate, Color(1, 1, 1, 1), 0.07)
		else:
			modulate = lerp(modulate, Color(1, 1, 1, 0.4), 0.07)
		return;
	modulate = lerp(modulate, Color.TRANSPARENT, .2)
	if modulate.a <= .005:
		queue_free()

func switch():
	await get_tree().create_timer(2).timeout
	kys = true


func _on_button_mouse_entered() -> void:
	hover = true


func _on_button_mouse_exited() -> void:
	hover = false

func bump() -> void:
	hit.emit(pos)
