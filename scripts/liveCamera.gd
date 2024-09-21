extends Camera2D
class_name LiveCamera

var windowBounds : Vector2 = Vector2(0,0)
var focus : Node2D = null

func _ready():
	get_tree().get_root().size_changed.connect(on_resize)
	windowBounds = get_window().size
	

func _process(_delta):
	if focus == null:
		return;
	
	var camOffset : Vector2 = get_window().get_mouse_position()
	camOffset = camOffset/windowBounds
	camOffset.x = clamp(camOffset.x, 0, 1)
	camOffset.y = clamp(camOffset.y, 0, 1)
	var modify : Vector2 = Vector2(round(-100+(camOffset.x*200)), round(-100+(camOffset.y*200)))
	
	var target : Vector2 = focus.global_position
	target = target+modify
	global_position = lerp(global_position, target, .1)
	
	

func on_resize():
	windowBounds = get_window().size
