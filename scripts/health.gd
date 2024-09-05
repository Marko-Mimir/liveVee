extends Node2D
class_name Health

var health : float = 10;
var maxHealth : int = 10;

func initalize(maxHp : int):
	maxHealth = maxHp
	health = maxHp

func getHealth():
	return health; 

func editHealth(editHp : float):
	editHp = snapped(editHp, 0.01)
	health+=editHp;
	health = snapped(health, 0.01)
	if health > maxHealth:
		health = maxHealth;
	if health < 0:
		health = 0;
	return health


