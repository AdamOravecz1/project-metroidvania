
@tool
extends Node2D

@export var platform_texture: Texture2D:
	set(value):
		platform_texture = value
		update_platform()

@export_range(16, 1024, 1) var platform_length: int = 64:
	set(value):
		platform_length = value
		update_platform()

@export var show_start: bool = true:
	set(value):
		show_start = value
		if is_node_ready():
			start_sprite.visible = value

@export var show_end: bool = true:
	set(value):
		show_end = value
		if is_node_ready():
			end_sprite.visible = value

@onready var start_sprite: Sprite2D = $Start
@onready var middle_container: Node2D = $Middle
@onready var end_sprite: Sprite2D = $End
@onready var collision: CollisionShape2D = $StaticBody2D/CollisionShape2D


func _ready() -> void:
	update_platform()


func update_platform() -> void:
	if not is_inside_tree():
		return

	if not is_node_ready():
		return

	if platform_texture == null:
		return

	start_sprite.texture = platform_texture
	start_sprite.region_enabled = true
	start_sprite.region_rect = Rect2(0, 0, 8, 8)
	start_sprite.position = Vector2(4, 4)

	for child in middle_container.get_children():
		middle_container.remove_child(child)
		child.free()

	var middle_count = platform_length / 8 - 2
	var remainder = platform_length % 8

	for i in range(middle_count):
		var sprite = Sprite2D.new()
		sprite.texture = platform_texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(8, 0, 8, 8)
		sprite.position = Vector2(12 + i * 8, 4)

		middle_container.add_child(sprite)

		if Engine.is_editor_hint():
			sprite.owner = get_tree().edited_scene_root

	# Add an extra overlapping middle segment for the remainder.
	if remainder > 0:
		var sprite = Sprite2D.new()
		sprite.texture = platform_texture
		sprite.region_enabled = true
		sprite.region_rect = Rect2(8, 0, 8, 8)

		var last_position = 12 + (middle_count - 1) * 8
		sprite.position = Vector2(last_position + remainder, 4)

		middle_container.add_child(sprite)

		if Engine.is_editor_hint():
			sprite.owner = get_tree().edited_scene_root

	# Position the end after the last middle segment.
	var end_position = platform_length - 4
	end_sprite.position = Vector2(end_position, 4)
	end_sprite.texture = platform_texture
	end_sprite.region_enabled = true
	end_sprite.region_rect = Rect2(16, 0, 8, 8)

	var shape = RectangleShape2D.new()
	shape.size = Vector2(platform_length, 2)

	collision.shape = shape
	collision.position = Vector2(platform_length / 2.0, 2)

	start_sprite.visible = show_start
	end_sprite.visible = show_end
