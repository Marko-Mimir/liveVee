extends GridContainer
class_name IGO



func output(text):
	var r := IGO.rich.new(text);
	add_child(r)
	r.start()

class rich:
	extends RichTextLabel
	
	var time : Timer
	var is_dead : bool = false
	
	func _init(txt : String) -> void:
		text = txt
		bbcode_enabled = true
		var s = get_theme_default_font().get_string_size(txt)
		s.x -=20
		autowrap_mode = TextServer.AUTOWRAP_OFF
		clip_contents = false
		custom_minimum_size = s
	
	func start():
		time = Timer.new()
		time.wait_time = 2
		time.timeout.connect(self.switch)
		add_child(time)
		time.start()
	
	func switch():
		is_dead = true
	
	func _process(_delta: float) -> void:
		if is_dead:
			modulate = lerp(modulate, Color.TRANSPARENT, 0.1)
			if modulate.a < 0.01:
				time.queue_free()
				queue_free()
