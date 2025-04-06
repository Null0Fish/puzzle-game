extends Node

# Bomb information
const ADJACENT : int = 0
const DIAGONAL : int = 1
const FULL : int = 2
const LAST_BOMB : int = FULL
const MAX_BOMB_LEVEL : int = 2
const NONE : Array = [0, 0, 0]

# Tile information
const PLAYER_SIZE : float = 8.0
const TILE_SIZE : float = 16.0
const GUI_TILES : Array = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0)
]

# Level information
const MAX_LEVELS : int = 6
const BOMBS_AVAILABLE : Array = [
	NONE,
	NONE,
	[3, 3, 3],
	[0, 1, 0],
	[1, 1, 1],
	[2, 2, 2],
	[0, 2, 1],
	[2, 2, 2],
	[3, 3, 3],
	[1, 2, 1],
	[3, 2, 3]
]

const LEVEL_FILE : String = "res://content/levels/level_"

# State variables
var paused : bool = false
var current_bomb_type : int = DIAGONAL
var bomb_levels : Array = [0, 0, 0]
var unlocked_levels : Array = [0]

# Functions
func get_bombs_available(level : int) -> Array:
	if BOMBS_AVAILABLE.size() >= level + 1:
		return BOMBS_AVAILABLE[level].duplicate()
	return NONE.duplicate()

func set_level(level_num : int):
	if level_num <= MAX_LEVELS:
		get_tree().change_scene_to_file(LEVEL_FILE + str(level_num) + ".tscn")
	else:
		print("Uh oh no more levels D;")

func get_current_level() -> int:
	return get_tree().current_scene.scene_file_path.to_int()

func reset():
	current_bomb_type = DIAGONAL
	bomb_levels = [0, 0, 0]
	get_tree().reload_current_scene()
