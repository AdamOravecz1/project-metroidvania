extends Area2D

@onready var fg_tile_map = get_parent()


func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("hetg")
		var tween = get_tree().create_tween()
		tween.tween_property(fg_tile_map, "self_modulate", Color(0.0, 0.0, 0.0, 0.0), 0.5)
		for black_rectangle in fg_tile_map.get_children():
			black_rectangle.modulate = Color(0.0, 0.0, 0.0, 0.0)


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()

		tween.tween_property(fg_tile_map, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
		await get_tree().create_timer(.25, false).timeout
		var rectangle_tween = get_tree().create_tween()

		for black_rectangle in fg_tile_map.get_children():
			rectangle_tween.parallel().tween_property(black_rectangle, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
