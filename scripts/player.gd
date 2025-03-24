extends CharacterBody2D
class_name Player

const PLAYER_SIZE = Global.PLAYER_SIZE

const SPEED : float = 75.0
const JUMP_VELOCITY : float = -280.0

@onready var sprite : Sprite2D = $PlayerSprite
@onready var window_size = get_viewport_rect().size

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor() and not Global.paused:
		velocity.y = JUMP_VELOCITY
	
	if not Global.paused:
		var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
		velocity.x = direction * SPEED
	else:
		velocity.x = 0

	move_and_slide()

	position.x = clamp(
		position.x, 
		PLAYER_SIZE / 2.0, 
		window_size.x - PLAYER_SIZE / 2.0
	)
	position.y = clamp(
		position.y, 
		PLAYER_SIZE / 2.0, 
		window_size.y - PLAYER_SIZE / 2.0
	)

	update_facing_direction()

func update_facing_direction():
	if velocity.x > 0:
		sprite.flip_h = false
	elif velocity.x < 0:
		sprite.flip_h = true

func die():
	Global.call_deferred("reset")
