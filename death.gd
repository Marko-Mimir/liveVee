extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body == player:
		player.scene.respawn()


func _on_area_entered(area: Area2D) -> void:
	area.queue_free()
	print("Object is Out of Bounds.")
