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
const OFFSET : Vector2i = Vector2i(8, 8)
const GUI_TILES : Array = [
	Vector2i(0, 0),
	Vector2i(1, 0),
	Vector2i(2, 0)
]

# Level information
const LEVEL_FILE : String = "res://content/levels/level_"
const MAX_LEVELS : int = 19
const BOMBS_AVAILABLE : Array = [
	NONE,
	NONE,
	[3, 3, 3],
	[0, 1, 0],
	[2, 2, 2],
]
var current_level_num : int = 0
var has_restarted : bool = false

# GUI Information
const GUI_CELLS : Array = [
	Vector2i(8,0),
	Vector2i(9,0),
	Vector2i(10,0),
	Vector2i(11,0),
]

# Lava tint variables
var lava_tint: Color = Color(1.0, 1.0, 1.0)
var base_tint: Color = Color(1.0, 1.0, 1.0)
var peak_tint: Color = Color(1.0, 0.7, 0.3)
var tint_speed: float = 1.0 
var tint_phase: float = 0.0

# Music Player variables
const MIN_VOL: int = -16
const MAX_VOL: int = -8
const MUSIC_FILE: AudioStreamMP3 = preload("res://assets/sounds/background.mp3")
var audio_player: AudioStreamPlayer

# State variables
var paused : bool = false
var current_bomb_type : int = DIAGONAL
var bomb_levels : Array = [0, 0, 0]
var unlocked_levels : Array = [0]
var solid_warning_layers : Array = []

# Functions
func _ready():
	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.stream = MUSIC_FILE
	audio_player.finished.connect(_play_audio)
	lower_audio_vol()
	_play_audio()

func lower_audio_vol():
	audio_player.volume_db = MIN_VOL

func _play_audio():
	audio_player.volume_db = MAX_VOL
	audio_player.play()

func try_play_background_music():
	audio_player.volume_db = MAX_VOL
	if not audio_player.playing:
		_play_audio()

func _process(delta: float) -> void:
	tint_phase += delta * tint_speed
	var t = (sin(tint_phase) + 1.0) / 2.0
	lava_tint = base_tint.lerp(peak_tint, t)

func get_bombs_available(level : int) -> Array:
	if level == -1:
		return [9, 9, 9]
	if BOMBS_AVAILABLE.size() >= level + 1:
		return BOMBS_AVAILABLE[level].duplicate()
	return NONE.duplicate()

func has_solid_warning_tile_at(cell : Vector2i):
	for solid_warning_layer in solid_warning_layers:
		if solid_warning_layer.get_cell_source_id(cell) != -1:
			return true
	return false

func set_level(level_num : int):
	if level_num <= MAX_LEVELS:
		reset()
		current_level_num = level_num
		get_tree().change_scene_to_file(LEVEL_FILE + str(level_num) + ".tscn")
	else:
		print("ERROR NO MORE LEVELS")
		get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")

func get_current_level() -> int:
	return get_tree().current_scene.scene_file_path.to_int()

func restart():
	has_restarted = true
	current_bomb_type = DIAGONAL
	bomb_levels = [0, 0, 0]
	solid_warning_layers = []
	get_tree().reload_current_scene()

func reset():
	has_restarted = false
	current_bomb_type = DIAGONAL
	bomb_levels = [0, 0, 0]
	solid_warning_layers = []
	get_tree().reload_current_scene()

func type_to_string(type : int):
	if type == ADJACENT:
		return "Adjacent"
	if type == DIAGONAL:
		return "Diagonal"
	if type == FULL:
		return "Full"
