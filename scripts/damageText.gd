extends Marker2D
class_name damageNumber

var label : Label
@export var critTheme : Theme;
var damage : int = 0
var crit : bool = false




func _ready():
	label = get_node("Label")
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1,1), 0.1)
	
	label = get_node("Label")
	label.text = str(damage)
	if crit:
		label.theme = critTheme
		label.text = label.text+"!"


func _on_timer_timeout():
	queue_free()
