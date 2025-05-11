extends Area2D
class_name Chest

@onready var timer: Timer = $Timer
@onready var win_particles: Node2D = $WinParticles
@onready var fade: Control = $Fade
@onready var win_audio: AudioStreamPlayer = $WinAudio
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var open_texture: Texture = preload("res://assets/chest/open_chest.png")

var next_level: int
var currently_dieing: bool = false

func _on_body_entered(body: Node):
	if body is Player and not currently_dieing:
		currently_dieing = true
		sprite_2d.texture = open_texture
		next_level = Global.get_current_level() + 1
		if not Global.unlocked_levels.has(next_level):
			Global.unlocked_levels.append(next_level)
		Global.paused = true
		win_particles.show()
		var tween = create_tween()
		tween.tween_property(body, "global_position", global_position, .25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(Callable(self, "_on_player_centered"))

func _on_player_centered():
	timer.start(1.65)
	win_audio.play()

func _on_timer_timeout():
	await fade.fade_out()
	Global.set_level(next_level)
