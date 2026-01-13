extends Line2D
class_name LiveTrackVisualizer

@export var keyframeImage : CompressedTexture2D

var maxTime : float = 1.0
var length := 540

func visualize(track : LiveAnimationTrack, maximum_time : float):
	maxTime = maximum_time
	for n in get_children():
		n.queue_free()
	for frame in track.keyframes:
		var curr : Sprite2D
		curr = Sprite2D.new()
		curr.texture = keyframeImage
		add_child(curr)
		
		curr.position.x = -270
		curr.position.x += getPositionOnLine(frame.time)
		curr.visible = true

func getPositionOnLine(time : float) -> float:
	if time > maxTime:
		return length
	var step = length/(maxTime/0.01)
	return step*(time*100)
