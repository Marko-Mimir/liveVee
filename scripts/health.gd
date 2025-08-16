extends Node2D
class_name Health

signal dead

var health : float = 10;
@export var maxHealth : int = 10;
@export var bar : ProgressBar

func _ready() -> void:
	if bar:
		bar.max_value = maxHealth
		bar.value = maxHealth
	health = maxHealth

func getHealth():
	return health; 

func editHealth(editHp : float):
	editHp = snapped(editHp, 0.01)
	health+=editHp;
	health = snapped(health, 0.01)
	if health > maxHealth:
		health = maxHealth;
	if bar:
		bar.value = health
	if health < 0 or health == 0:
		health = 0;
		dead.emit()
	return health
