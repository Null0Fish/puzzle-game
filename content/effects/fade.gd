extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func fade_out():
	visible = true
	animation_player.play("fade_out")
	await animation_player.animation_finished
	return

func fade_in():
	visible = true
	animation_player.play("fade_in")
	await animation_player.animation_finished
	visible = false
	return
