extends Area2D

class_name Chest

@onready var open_texture: Texture = preload("res://assets/chest/open_chest.png")
@onready var timer: Timer = $Timer
@onready var win_particles: Node2D = $WinParticles
@onready var fade: Control = $Fade

var next_level: int

func _ready() -> void:
	pass
	#fade.fade_in()

func _on_body_entered(body : Node):
	if body is Player:
		$Sprite2D.texture = open_texture
		next_level = Global.get_current_level() + 1
		if not Global.unlocked_levels.has(next_level):
			Global.unlocked_levels.append(next_level)
		Global.paused = true
		win_particles.show()
		timer.start(1.65)

func _on_timer_timeout():
	await fade.fade_out()
	Global.set_level(next_level)
