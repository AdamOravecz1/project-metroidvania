extends Area2D

@onready var fg_tile_map = get_parent()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("hetg")
		var tween = get_tree().create_tween()
		tween.tween_property(fg_tile_map, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.5)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(fg_tile_map, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
