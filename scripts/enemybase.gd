extends Node2D
class_name Enemy

var damageText = preload("res://objects/damageText.tscn")

signal hurt
signal dead
@export var hurtbox : Area2D
@export var healthManager : Health;
@export var healthLabel : Label
var hurted = false
var hitstop : Timer
var counter = -1
var player : Character;

func _ready():
	healthManager.initalize(100)
	player=get_window().get_child(0)

func _on_hurtbox_area_entered(_area):
	hurtCheck()

func hurtCheck():
	if counter == player.slashCounter:
#Sometimes the sweet and sour spot will both emit, this is to stop that
		return
	counter = player.slashCounter
	
	var sour = hurtbox.overlaps_area(player.getSour())
	var damage = player.damage(sour)
	
	healthManager.editHealth(-damage)

	var num : damageNumber = damageText.instantiate()
	num.crit = (damage >= 20)
	num.damage = damage
	num.position = global_position + Vector2(randi_range(-20,20), randi_range(-20,20))
	get_window().add_child(num)
	
	if healthManager.getHealth() == 0:
		emit_signal("dead")
	else:
		emit_signal("hurt")
