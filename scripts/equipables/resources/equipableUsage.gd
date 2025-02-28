extends Resource
class_name equipableUsage
	
@export var name := ""
@export var directions := []
@export var smear_texture : Texture2D
@export var start : Dictionary;
@export var end : Dictionary
@export var smear : Dictionary
@export var smear_collision : Array[PackedVector2Array]
