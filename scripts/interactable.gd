extends Area2D
class_name AOI

@export var sprite : Sprite2D;
@export var doAutoWalk : bool = false;


var isPlayer := false
var outline := preload("res://resources/outline.gdshader")
var test : RichTextLabel

signal action

func _ready() -> void:
	if sprite == null:
		print_rich(util.translateAltColorCodes("&", "&4"+name+": No sprite avaliable, attach one via editor, queue'd free."))
		queue_free()
		return
	sprite.material = ShaderMaterial.new()
	sprite.material.shader = outline
	sprite.material.set_shader_parameter("width", 0.0)
	mouse_entered.connect(self.onMouse)
	mouse_exited.connect(self.mouseLeave)
	input_event.connect(self.onclick)

func onMouse() -> void:
	sprite.material.set_shader_parameter("width",1.0)
func mouseLeave()->void:
	sprite.material.set_shader_parameter("width",0.0)

func onclick(_viewport:Node, event:InputEvent, _shape_idx:int)-> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == 1:
		if player.can_interact(self):
			action.emit()
		else:
			if doAutoWalk:
				player.set_aoi(self)


func _on_area_entered(_area: Area2D) -> void:
	isPlayer = true

func _on_area_exited(_area: Area2D) -> void:
	isPlayer = false
