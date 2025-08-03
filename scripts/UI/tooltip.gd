extends PanelContainer
var titleLabel :RichTextLabel
var desc :RichTextLabel
var base = ""
var isShowing = false

func _ready() -> void:
	modulate.a = 0
	titleLabel = get_child(0).get_child(0)
	desc = get_child(0).get_child(1)
	base = titleLabel.text

func startTooltip(title : String, description : String):
	isShowing = true
	titleLabel.text = base.replace("&", util.translateAltColorCodes("&",title))
	desc.text = util.translateAltColorCodes("&", description)
	var m = get_minimum_size()
	if m.y < 179:
		size = m

func endTooltip():
	isShowing = false
	

func _process(_delta: float) -> void:
	if isShowing:
		if !modulate.a >= 1:
			modulate.a = lerpf(modulate.a, 1, 0.2)
		global_position = get_global_mouse_position() + Vector2(20,20)
	else:
		if !modulate.a <= 0:
			modulate.a = lerpf(modulate.a, 0, 0.2)
