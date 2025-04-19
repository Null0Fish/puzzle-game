extends CharacterBody2D

class_name Player

@onready var sprite: AnimatedSprite2D = $PlayerSprite
@onready var window_size = get_viewport_rect().size
@onready var die_player: AudioStreamPlayer = $DiePlayer
@onready var jump_player: AudioStreamPlayer = $JumpPlayer

const PLAYER_SIZE = Global.PLAYER_SIZE
const SPEED: float = 75.0
const JUMP_VELOCITY: float = -280.0
const COYOTE_TIME: float = 0.05  

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer: float = 0.0
var is_dead: bool = false

func _physics_process(delta):
	if is_dead:
		velocity = Vector2(0, velocity.y)
		move_and_slide()
		return
	
	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		coyote_timer -= delta
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if Input.is_action_just_pressed("jump") and coyote_timer > 0.0 and not Global.paused:
		jump_player.play()
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

var death_scene: PackedScene = preload("res://content/other/death_animation.tscn")

func die():
	Global.paused = true
	# Replace with propper animation
	sprite.play("dead")
	if not is_dead:
		var death_animation = death_scene.instantiate()
		add_child(death_animation)
		death_animation.position = sprite.position
		death_animation.z_index = 10
		is_dead = true
		die_player.play()
		await die_player.finished
		await death_animation.finished
		Global.call_deferred("reset")
