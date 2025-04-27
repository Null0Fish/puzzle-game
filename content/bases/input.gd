extends Control

@onready var level_base: Node2D = $".."
@onready var root_tile_layer: TileMapLayer = $"../RootTileLayer"

func _input(event):
	if Global.paused:
		return
		
	if event.is_action_released("restart_level"):
		Global.restart()
	
	if event.is_action_released("exit"):
		# Global.stop_audio()
		get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")
	
	for key in range(KEY_0, KEY_9 + 1):
		if Input.is_key_pressed(key):
			Global.current_bomb_type = clamp(int(char(key)) - 1, 0, Global.LAST_BOMB)
	
	if event is InputEventMouseButton and event.is_released():
		var cell: Vector2i = root_tile_layer.local_to_map(event.position)
		if level_base.bomb_locations.has(cell):
			if event.button_index == MOUSE_BUTTON_RIGHT:
				level_base.try_detonate_bomb(cell)
