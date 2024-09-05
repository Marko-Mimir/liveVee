extends RigidBody2D
class_name Enemy

signal hurt
signal dead
@export var healthManager : Health;
@export var healthLabel : Label

func _ready():
	healthManager.initalize(50)

func _on_hurtbox_area_entered(area):
	var player : Character = get_node("%player")
	if player.damage == null:
		return;
	else:
		healthManager.editHealth(-player.damage)
		healthLabel.text = "Health "+str(healthManager.health)+"pts"
		if healthManager.getHealth() == 0:
			print_rich("[color=red][wave]#dead lmao")
			emit_signal("dead")
		else:
			print("Yowch!")
			emit_signal("hurt")
		
