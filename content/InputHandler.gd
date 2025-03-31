extends Control

const LAST_BOMB = Global.LAST_BOMB

@onready var tilemap = $"../GlobalTileMap"
@onready var level_base = $".."
@onready var player = $"../Player"

func _input(event):
	if Global.paused:
		return
	
	var current_bomb_type = Global.current_bomb_type
	if event is InputEventMouseButton and event.is_released():
		print("mosue input found")
		var cell = tilemap.local_to_map(event.position)
		# Disables clicking on GUI
		if cell.y > 0:
			if event.button_index == MOUSE_BUTTON_LEFT:
				level_base.handle_left_click(cell)
			elif event.button_index == MOUSE_BUTTON_RIGHT and level_base.bomb_locations.has(cell):
				level_base.handle_right_click(cell)
	
	if event.is_action_released("restart_level"):
		Global.reset()
	
	for key in range(KEY_0, KEY_9 + 1):
		if Input.is_key_pressed(key):
			Global.current_bomb_type = clamp(int(char(key)) - 1, 0, LAST_BOMB)
