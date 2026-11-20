extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_velocity: float = 450.0
@export var gravity: float = 1000.0

@export var jump_cut_multiplier: float = 0.4
@export var coyote_time: float = 0.12

var coyote_timer: float = 0.0

var cutting: bool = false
var next_cut_right: bool = true

var sword_original_x: float

@onready var body_sprite: AnimatedSprite2D = $BodySprite
@onready var sword_sprite: AnimatedSprite2D = $SwordSprite
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	sword_original_x = abs(sword_sprite.position.x)

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Coyote time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Horizontal movement
	var direction := Input.get_axis("left", "right")
	velocity.x = direction * speed

	# Jump
	if Input.is_action_just_pressed("up") and coyote_timer > 0.0:
		velocity.y = -jump_velocity
		coyote_timer = 0.0

	# Variable jump height
	if Input.is_action_just_released("up") and velocity.y < 0.0:
		velocity.y *= jump_cut_multiplier
		
	# Drop down
	if Input.is_action_pressed("down"):
		set_collision_mask_value(2, false)
	else:
		set_collision_mask_value(2, true)

	# Cut
	if Input.is_action_just_pressed("cut") and not cutting:
		cutting = true
		
		sword_sprite.play("cut")
		sword_sprite.flip_v = false if next_cut_right else true

		var animation_name = "cut_right" if next_cut_right else "cut_left"
		
		if body_sprite.animation == "idle" or body_sprite.animation == "cut_left" or body_sprite.animation == "cut_right":
			body_sprite.play(animation_name)

		next_cut_right = not next_cut_right

	move_and_slide()

	# Sprite direction
	if direction != 0.0:
		body_sprite.flip_h = direction < 0.0
	if not cutting:
		sword_sprite.flip_h = body_sprite.flip_h
		sword_sprite.position.x = -sword_original_x if body_sprite.flip_h else sword_original_x

	# Movement animations
	if not is_on_floor():
		if velocity.y < 0.0:
			body_sprite.play("jump_up")
		elif body_sprite.animation != "jump_down":
			body_sprite.play("jump_down")

	elif direction != 0.0:
		if body_sprite.animation == "jump_up" or body_sprite.animation == "jump_down":
			body_sprite.play("run")
		elif body_sprite.animation != "run_start" and body_sprite.animation != "run":
			body_sprite.play("run_start")

	elif body_sprite.animation != "cut_right" and body_sprite.animation != "cut_left":
		body_sprite.play("idle")


func _on_sword_sprite_animation_finished() -> void:
	if sword_sprite.animation == "cut":
		sword_sprite.play("idle")
		cutting = false


func _on_body_sprite_animation_finished() -> void:
	if body_sprite.animation == "run_start":
		body_sprite.play("run")
	if body_sprite.animation == "cut_right" or body_sprite.animation == "cut_left":
		body_sprite.play("idle")
