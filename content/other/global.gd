extends Node

# Bomb information
const ADJACENT : int = 0
const DIAGONAL : int = 1
const FULL : int = 2
const LAST_BOMB : int = FULL
const MAX_BOMB_LEVEL : int = 2

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
const MAX_LEVELS : int = 20
var current_level_num : int = 0
var has_restarted : bool = false

# GUI Information
const GUI_CELLS : Array = [
	Vector2i(8,0),
	Vector2i(9,0),
	Vector2i(10,0),
	Vector2i(11,0),
]

# Colors
const ACTIVE_COLOR: Color = Color("#3b2027")
const INACTIVE_COLOR: Color = Color("#21181b")

# Lava tint variables
var lava_tint: Color = Color("#FFFFFF")
var base_tint: Color = Color("#FFA642")
var peak_tint: Color = Color("#FFE6A6")
var tint_speed: float = 1.0
var tint_phase: float = 0.0

# Music Player variables
const MIN_VOL: int = -16
const MAX_VOL: int = -8
const MUSIC_FILE: AudioStreamMP3 = preload("res://assets/sounds/background.mp3")
var background_audio: AudioStreamPlayer

# State variables
var paused : bool = false
var current_bomb_type : int = DIAGONAL
var bomb_levels : Array = [0, 0, 0]
var unlocked_levels : Array = [0]
var solid_warning_layers : Array = []
var question_mark_override: bool = false

# Functions
func _ready():
	background_audio = AudioStreamPlayer.new()
	add_child(background_audio)
	background_audio.stream = MUSIC_FILE
	background_audio.finished.connect(_play_audio)
	lower_audio_vol()
	_play_audio()

func lower_audio_vol():
	background_audio.volume_db = MIN_VOL

func _play_audio():
	background_audio.volume_db = MAX_VOL
	background_audio.play()

func try_play_background_music():
	background_audio.volume_db = MAX_VOL
	if not background_audio.playing:
		_play_audio()

func _process(delta: float) -> void:
	tint_phase += delta * tint_speed
	var t = (sin(tint_phase) + 1.0) / 2.0
	lava_tint = base_tint.lerp(peak_tint, t)

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
		# No more levels
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
