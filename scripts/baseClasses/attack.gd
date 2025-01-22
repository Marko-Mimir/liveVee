extends Node2D
class_name Attack
@export_category("Animation Setup")
@export var animation_length : float = 1
@export var animation_steps : Array[Array] = [[0.0,"",0],[0.0,"",0],[0.0,"",0]];
@export var attack_name : String = "";
@export var attack_curve : Curve;
@export var uptodown : bool = false;
@export_category("Weapon Config")
@export_enum("sword", "class2", "class3") var weapon_type : int
@export_category("debug")
@export var debug : bool = false

var animation = Animation.new()
var tracks : Dictionary = {}
var points : Array = []

func _ready() -> void:
	var i = 0
	var len = attack_curve.point_count-1
	for x in attack_curve.point_count:
		var c = attack_curve.get_point_position(x)
		points.append(Vector2(c.y, -((c.x-.5)*2))) #rotate 90 deg clockwise.
		i+=1
	if uptodown:
		points.reverse()


func _draw() -> void:
	if !debug: return;
	if points == []: return;
	var first = points[0]
	for x in points:
		if x != first:
			draw_circle(x*45, 3, Color.RED)
		else:
			draw_circle(x*45, 3, Color.GREEN)

func get_animation() -> Animation:
	var name = animation_steps[1][1];
	tracks[name] = animation.add_track(Animation.TYPE_VALUE)
	animation.track_set_path(tracks[name], name)
	animation.length = animation_length
	
	for x in animation_steps:
		if x[1] != name:
			if x[1] not in tracks.keys():
				tracks[x[1]] = animation.add_track(Animation.TYPE_VALUE)
				animation.track_set_path(tracks[x[1]], x[1])
		animation.track_insert_key(tracks[x[1]], x[0], x[2])
	return animation;
