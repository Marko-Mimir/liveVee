extends Node2D
class_name liveScene

@export var spawn : Marker2D;
var player : Character

func _ready():
	player = get_window().get_child(0)
	player.position = spawn.position
