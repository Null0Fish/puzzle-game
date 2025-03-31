extends Control

const LAST_BOMB = Global.LAST_BOMB

@onready var tilemap: TileMapLayer = $"../GlobalTileMap"
@onready var level_base: Node = $".."
@onready var player: CharacterBody2D = $"../Player"

func _input(event: InputEvent):
	if Global.paused:
		return
	
	var current_bomb_type = Global.current_bomb_type
	
	if event is InputEventMouseButton and event.is_released():
		var cell: Vector2i = tilemap.local_to_map(event.position)
		if event.button_index == MOUSE_BUTTON_LEFT:
			level_base.handle_left_click(cell)
		elif event.button_index == MOUSE_BUTTON_RIGHT and level_base.bomb_locations.has(cell):
			level_base.handle_right_click(cell)
	if event.is_action_released("restart_level"):
		Global.reset()
	
	for key in range(KEY_0, KEY_9 + 1):
		if Input.is_key_pressed(key):
			Global.current_bomb_type = clamp(int(char(key)) - 1, 0, LAST_BOMB)
