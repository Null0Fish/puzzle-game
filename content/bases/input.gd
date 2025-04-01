extends Control

@onready var level_base: Node2D = $".."
@onready var tilemap: TileMapLayer = $"../GlobalTileMap"

func _input(event):
	if Global.paused:
		return
		
	if event.is_action_released("restart_level"):
		Global.reset()
		
	for key in range(KEY_0, KEY_9 + 1):
		if Input.is_key_pressed(key):
			Global.current_bomb_type = clamp(int(char(key)) - 1, 0, Global.LAST_BOMB)
	
	if event is InputEventMouseButton and event.is_released():
		var cell: Vector2i = tilemap.local_to_map(event.position)
		if level_base.bomb_locations.has(cell):
			if event.button_index == MOUSE_BUTTON_RIGHT:
				level_base.try_detonate_bomb(cell)
			if event.button_index == MOUSE_BUTTON_LEFT:
				level_base.try_pick_up_bomb(cell)
