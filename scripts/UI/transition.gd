extends LiveUi

var rect : ColorRect
signal half
var flip:= false


func _ready() -> void:
	rect = $ColorRect

func _process(delta: float) -> void:
	if !rect:
		return
	if flip:
		rect.color.a = lerpf(rect.color.a, 0, .05)
		if rect.color.a <= 0.001:
			await get_tree().create_timer(1).timeout
			queue_free()
	else:
		rect.color.a = lerpf(rect.color.a, 1, .05)
		if rect.color.a >= .99:
			await get_tree().create_timer(.5).timeout
			half.emit()
			await get_tree().create_timer(.5).timeout
			flip = true
