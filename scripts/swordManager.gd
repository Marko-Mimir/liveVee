extends Node2D
class_name SwordManager

var radius = 40
@export var shoulder : Marker2D;
var currentSword : SwordBase = null

func _ready() -> void:
	player.swordManager = self


func _process(_delta: float) -> void:
	var mouse : Vector2 = get_global_mouse_position()
	var plyrPos : Vector2 = shoulder.global_position
	
	if(mouse.distance_to(plyrPos) < radius):
		global_position = mouse
		currentSword.global_position = mouse
	else:
		global_position = shoulder.to_global(shoulder.get_local_mouse_position().normalized() * radius)
		if currentSword:
			currentSword.global_position = shoulder.to_global(lerp(shoulder.get_local_mouse_position().normalized(), Vector2(0,1), 0.3) * (radius))
		

func add_sword(sword : SwordBase) -> void:
	if currentSword != null:
		remove_child(currentSword)
	add_child(sword)
	player.get_fabrik().target_nodepath = sword.get_handle().get_path()
	currentSword = sword
