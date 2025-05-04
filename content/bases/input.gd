extends Control

@onready var level_base: Node2D = $".."
@onready var root_tile_layer: TileMapLayer = $"../RootTileLayer"
@onready var player: Player = $"../Player"
@onready var fade: ColorRect = $"../Fade"
@onready var timer: Timer = $Timer

var should_fade: bool = false

func _process(_delta: float) -> void:
	if should_fade:
		fade.modulate.a += 0.04

func _input(event):
	if Global.paused:
		return
	
	if event.is_action_released("restart_level"):
		player.die()
	
	if event.is_action_released("exit"):
		if not should_fade:
			Global.paused = true
			if level_base.should_fade:
				await level_base.fade_finished
			should_fade = true
			timer.start(.75)
	
	for key in range(KEY_0, KEY_9 + 1):
		if Input.is_key_pressed(key):
			Global.current_bomb_type = clamp(int(char(key)) - 1, 0, Global.LAST_BOMB)
	
	if event is InputEventMouseButton and event.is_released():
		var cell: Vector2i = root_tile_layer.local_to_map(event.position)
		if level_base.bomb_locations.has(cell):
			if event.button_index == MOUSE_BUTTON_RIGHT:
				level_base.try_detonate_bomb(cell)


func _on_timer_timeout() -> void:
	Global.lower_audio_vol()
	get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")
	
