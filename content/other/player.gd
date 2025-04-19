extends CharacterBody2D

class_name Player

@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var window_size = get_viewport_rect().size
@onready var die_player: AudioStreamPlayer = $DiePlayer

const PLAYER_SIZE = Global.PLAYER_SIZE
const SPEED: float = 75.0
const JUMP_VELOCITY: float = -280.0
const COYOTE_TIME: float = 0.05  

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var is_frozen: bool = false

func _physics_process(delta):
	if is_frozen:
		velocity = Vector2.ZERO
		return
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0 and not Global.paused:
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0  
	
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
	
	_update_facing_direction()

func _update_facing_direction():
	if velocity.x < 0:
		sprite.play("run_left")
	elif velocity.x > 0:
		sprite.play("run_right")
	else:
		sprite.play("idle")

var currently_dieing = false

func die():
	Global.paused = true
	is_frozen = true
	sprite.play("idle")
	if not currently_dieing:
		currently_dieing = true
		die_player.play()
		await die_player.finished
		Global.call_deferred("restart")
