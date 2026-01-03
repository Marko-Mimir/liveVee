@tool
class_name DraggableSprite2D extends Area2D
## A draggable sprite that can be dragged using the left mouse button.

signal grabbed
signal released

@export var grabbable := true
@export var centerDrag := false
@export var input_method: MouseButton = MOUSE_BUTTON_LEFT

# === NEW: spritesheet support ===
@export var hframes := 1 :
	set(value):
		hframes = max(1, value)
		sprite.hframes = hframes
		update_default_collider()

@export var vframes := 1 :
	set(value):
		vframes = max(1, value)
		sprite.vframes = vframes
		update_default_collider()

@export var frame := 0 :
	set(value):
		frame = value
		sprite.frame = frame

@export var texture : Texture2D :
	set(value):
		texture = value
		sprite.texture = texture
		update_default_collider()

@export var return_to_origin := false
@export var origin := Vector2.ZERO

var sprite := Sprite2D.new()
var default_collider : CollisionShape2D

var is_grabbed := false :
	set(value):
		is_grabbed = value
		if is_grabbed:
			grabbed.emit()
		else:
			released.emit()

var grabbed_offset := Vector2.ZERO
var mb_pressed = false


func _ready() -> void:
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	input_event.connect(_on_input_event)

	add_child(sprite)

	# Ensure sprite settings are synced
	sprite.texture = texture
	sprite.hframes = hframes
	sprite.vframes = vframes
	sprite.frame = frame
	sprite.centered = true

	default_collider = CollisionShape2D.new()
	default_collider.shape = RectangleShape2D.new()

	update_default_collider()
	add_child(default_collider)

	if has_custom_collider():
		toggle_default_collider(false)

	if return_to_origin:
		origin = position


func _process(delta) -> void:
	if Input.is_mouse_button_pressed(input_method) and is_grabbed and grabbable:
		position = get_global_mouse_position() + grabbed_offset
		mb_pressed = true

	if not Input.is_mouse_button_pressed(input_method) and mb_pressed:
		if return_to_origin:
			position = origin
		mb_pressed = false


func has_custom_collider() -> bool:
	var children = get_children()
	children.erase(default_collider)
	for child in children:
		if child is CollisionShape2D or child is CollisionPolygon2D:
			return true
	return false


func toggle_default_collider(on: bool) -> void:
	default_collider.visible = on
	default_collider.disabled = not on


## UPDATED: collider matches ONE FRAME, not whole texture
func update_default_collider() -> void:
	if not default_collider or not default_collider.shape:
		return

	if not texture:
		default_collider.shape.size = Vector2.ZERO
		return

	var tex_size := texture.get_size()
	var frame_size := tex_size / Vector2(hframes, vframes)

	default_collider.shape.size = frame_size


func _on_input_event(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and grabbable:
		viewport.set_input_as_handled()
		is_grabbed = event.is_pressed()
		if not centerDrag:
			grabbed_offset = position - get_global_mouse_position()


func _on_child_entered_tree(child) -> void:
	if (child is CollisionShape2D or child is CollisionPolygon2D) and child != default_collider:
		toggle_default_collider(false)


func _on_child_exiting_tree(child) -> void:
	if (child is CollisionShape2D or child is CollisionPolygon2D) and child != default_collider:
		toggle_default_collider(true)
