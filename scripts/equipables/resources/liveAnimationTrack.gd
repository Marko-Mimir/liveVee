extends Resource
class_name LiveAnimationTrack

@export var trackPath : String
@export var keyframes : Array[LiveKeyframe]

func _init(t_path : String = "") -> void:
	trackPath = t_path
