extends Camera2D
class_name LiveCamera

var windowBounds : Vector2 = Vector2(0,0)
var focus : Node2D = null
var zoomtarg = 1

func _ready():
	get_tree().get_root().size_changed.connect(on_resize)
	zoom = Vector2(1,1)
	windowBounds = get_window().size

func _process(_delta):
	if focus == null:
		return;
	
	if zoomtarg != zoom.x:
		zoom.x = lerpf(zoom.x, zoomtarg, 0.1)
		if abs(zoomtarg-zoom.x) < 0.02:
			zoom.x = zoomtarg
		zoom.y = zoom.x
	
	var camOffset : Vector2 = get_window().get_mouse_position()
	camOffset = camOffset/windowBounds
	camOffset.x = clamp(camOffset.x, 0, 1)-.5
	camOffset.y = clamp(camOffset.y, 0, 1)-.5
	
	var target : Vector2 = focus.global_position
	target = target+(camOffset*150)
	global_position = lerp(global_position, target, .1)

func zoomto(to : int):
	#zoomtarg cannot be negative for now
	zoomtarg = abs(to)

func pullFocus(pull : Focusable):
	if pull == focus: return;
	focus = pull
	pull.release.connect(release)
	pull.isFocused = true

func release():
	if focus is Focusable:
		focus.release.disconnect(release)
		focus.isFocused = false
		focus = player
		return
	player.scene.gamePrint("&4Error: Focus isnt type of Focusable and release was called. focus:"+String(focus.get_path()))

func on_resize():
	windowBounds = get_window().size
	print(windowBounds)
