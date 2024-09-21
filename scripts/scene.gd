extends Node2D
class_name liveScene

@export var spawn : Marker2D;
@export var camera : LiveCamera;

func _ready():
	player.position = spawn.position
	player.scene = self
	camera.focus = player

func debug_collision_shape_visibility() -> void:
	var tree := get_tree()
	tree.debug_collisions_hint = not tree.debug_collisions_hint
	var node_stack: Array[Node] = [tree.get_root()]
	while not node_stack.is_empty():
		var node: Node = node_stack.pop_back()
		if is_instance_valid(node):
			if node is CollisionShape2D or node is CollisionPolygon2D:
				node.queue_redraw()
			node_stack.append_array(node.get_children())
