class_name ShakeComponent
extends Node2D

var current_shake = 0

@export var sprite: Node2D
@export var shake_amount: = 5.0
@export var shake_duration: = 1.0
var doshake = false

func shake():
	current_shake = shake_amount
	doshake = true


func _physics_process(delta: float) -> void:
	current_shake -= shake_amount * delta / shake_duration
	if current_shake < 0:
		current_shake = 0
	
	sprite.position = Vector2(randf_range(-current_shake, current_shake), randf_range(-current_shake, current_shake))
