extends Node2D

@onready var upgrade_audio: AudioStreamPlayer = $UpgradeAudio
@onready var timer: Timer = $Timer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var player_has_entered: bool = false

func _ready() -> void:
	_start_timer()

func _start_timer():
	timer.start(5)

func _on_timer_timeout() -> void:
	animated_sprite_2d.play("shine")
	_start_timer()

func _on_area_2d_body_entered(body):
	var current_bomb_type = Global.current_bomb_type
	var current_bomb_level = Global.bomb_levels[current_bomb_type]
	if body is Player and not player_has_entered:
		if current_bomb_level < Global.MAX_BOMB_LEVEL:
			player_has_entered = true
			get_tree().current_scene.upgrade_bomb_type(current_bomb_type)
			hide()
			upgrade_audio.pitch_scale = randf_range(.9, 1.3)
			upgrade_audio.play()
			await upgrade_audio.finished
			queue_free()
