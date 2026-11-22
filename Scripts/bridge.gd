extends Node2D
@onready var fg_tile_map: TileMapLayer = $FGTileMap


func _on_player_enter_checker_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(fg_tile_map, "modulate", Color(0.0, 0.0, 0.0, 0.0), 0.5)


func _on_player_enter_checker_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		var tween = get_tree().create_tween()
		tween.tween_property(fg_tile_map, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)
