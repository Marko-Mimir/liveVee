extends Node2D

@export var isfocus : bool = false
@export var focus : Color
@export var unfocus : Color
@export var target : Node2D;

var rest : Vector2

func _ready() -> void:
	rest = position
	rest.y += 20
	if isfocus:
		modulate = focus
	else:
		modulate = unfocus

func flip(val : bool) -> void:
	isfocus = !isfocus
	target.position = rest
	z_index = z_index*-1
	if isfocus:
		modulate = focus
	else:
		modulate = unfocus

func _process(delta: float) -> void:
	if isfocus:
		target.global_position = target.get_global_mouse_position()
