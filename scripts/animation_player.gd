extends Node
class_name LiveAnimationPlayer

@export var objects : Dictionary[String,Node]
@export var loop := true
var playing := false
var playAnimation : LiveAnimation = null
var internalTime := 0.0

func addKeyframe(anim : LiveAnimation, track_path : String, time: float, value : Variant) -> void:
	var current := findOrCreateTrack(anim, track_path)
	for keyframe in current.keyframes:
		if keyframe.time > time:
			break
		if keyframe.time == time:
			updateKeyframe(keyframe, value)
			return
	var keyframe = LiveKeyframe.new()
	keyframe.time = time
	keyframe.value = value
	current.keyframes.append(keyframe)
func updateKeyframe(keyframe : LiveKeyframe, value : Variant):
	print("Updated Keyframe. " + str(value)+","+ str(keyframe.time))
	keyframe.value = value

func findOrCreateTrack(anim : LiveAnimation, track_path : String) -> LiveAnimationTrack:
	for track in anim.tracks:
		if track.trackPath == track_path:
			print('Found existing track')
			return track
	print('New track created!')
	var track = LiveAnimationTrack.new(track_path)
	anim.tracks.append(track)
	return track

func getKeyframeAtTime(track : LiveAnimationTrack, time : float) -> Variant:
	track.keyframes.sort_custom(func(a,b):
		return a.time < b.time
		)
	var prev : LiveKeyframe = null
	for keyframe in track.keyframes:
		if is_equal_approx(keyframe.time, time):
			return keyframe.value
		#passed target time -> LERP
		if keyframe.time > time:
			#if before first keyframe
			if prev == null:
				return keyframe.value
			
			var t := (time - prev.time) / (keyframe.time - prev.time)
			return _interpolate(prev.value, keyframe.value, t)
		prev = keyframe
	
	#After last keyframe
	return prev.value

func _interpolate(a: Variant, b: Variant, t: float) -> Variant:
	match typeof(a):
		TYPE_FLOAT, TYPE_INT:
			return lerp(a, b, t)
		TYPE_VECTOR2:
			return a.lerp(b, t)
		TYPE_VECTOR3:
			return a.lerp(b, t)
		TYPE_COLOR:
			return a.lerp(b, t)
		TYPE_TRANSFORM2D:
			return a.interpolate_with(b, t)
		TYPE_TRANSFORM3D:
			return a.interpolate_with(b, t)
		_:
			# Unsupported type → snap to previous
			return a

func setActorsAtTime(anim : LiveAnimation, time : float) -> void:
	if time > anim.length:
		print("Invalid animation, requested time is out of range. Requested: "+str(time)+". Allowed: "+str(anim.length))
		return
	for track in anim.tracks:
		var value = getKeyframeAtTime(track, time)
		var actorPath = track.trackPath.get_slice(":", 0) if track.trackPath.contains(":") else track.trackPath
		var actor : Node = objects.get(actorPath)
		if ":" in track.trackPath:
			actor.set(track.trackPath.get_slice(":", 1), value)
		else:
			actor.set("position", value)

func _process(delta: float) -> void:
	if not playing:
		return
	if playAnimation == null:
		return
	internalTime += delta
	
	# Clamp or stop at animation end
	if internalTime >= playAnimation.length:
		if loop:
			internalTime = 0.0
		else:
			internalTime = playAnimation.length
			playing = false  # stop playback
		
	setActorsAtTime(playAnimation, internalTime)

func initPlay(anim : LiveAnimation, startTime : float = 0):
	playAnimation = anim
	internalTime = startTime

func playpause():
	playing = !playing
	print(playing)
