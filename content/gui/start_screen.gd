extends Control

@export var debug_enabled: bool = true

@onready var camera_2d: Camera2D = $Camera2D
@onready var label: Label = $TitleUI/ButtonContainer/PlayButton/Label
@onready var timer: Timer = $Timer
@onready var foreground_layer: TileMapLayer = $MenuTileLayers/ForegroundLayer
@onready var assets_credits_label: Label = $CreditsUI/HBoxContainer/VBoxContainer/AssetsCreditsLabel
@onready var fade: ColorRect = $Camera2D/Fade
@onready var level_grid: GridContainer = $MenuUI/LevelGrid

const HORIZONTAL_DELTA: Vector2 = Vector2(320, 0)
const VERTICAL_DELTA: Vector2 = Vector2(0, 192)
const CAMERA_MOVE_TIME: float = 1.5
const CREDITS_FILE: String = "res://metadata/credits.json"
const OFFSET: Vector2i = Global.OFFSET
const TILE_SIZE = Global.TILE_SIZE

var lava_scene: PackedScene = preload("res://content/level_specific/lava.tscn")

var max_level_num: int = 0
var block_input: bool = false

func _process(_delta: float) -> void:
	fade.modulate.a -= 0.01

func _ready():
	fade.show()
	_initialize_credits()
	_initialize_menu()
	_initialize_lava()

func _initialize_credits():
	var raw_data = JSON.parse_string(FileAccess.get_file_as_string(CREDITS_FILE))
	var formated_data = ""
	for key in raw_data.keys():
		var value = raw_data[key]
		if key != "":
			formated_data += "\n" + key + ": " + str(value) + "\n"
		else:
			formated_data += "\n" + str(value) + "\n"
	assets_credits_label.text = "\n" + formated_data

func _initialize_menu():
	for level in Global.unlocked_levels:
		max_level_num = max(max_level_num, level)
	label.text = "Resume" if max_level_num != 0 else "Play"

func _initialize_lava():
		for cell in foreground_layer.get_used_cells_by_id(1):
			var cell_data = foreground_layer.get_cell_tile_data(cell)
			if cell_data.get_custom_data("is_lava"):
				_initialize_scene_at(cell, lava_scene)

func _initialize_scene_at(cell: Vector2i, scene: PackedScene):
	var new_scene = scene.instantiate()
	add_child(new_scene)
	new_scene.position = _cell_to_cords(cell) + OFFSET
	foreground_layer.set_cell(cell, -1)
	return new_scene

func _cell_to_cords(cell: Vector2i):
	return Vector2i(cell.x * int(TILE_SIZE), cell.y * int(TILE_SIZE))

# TEMP DEBUG CODE
func _input(event):
	if debug_enabled:
		if event.is_action_released("debug_unlock_levels"):
			_unlock_levels()
		if event.is_action_released("debug_test_level"):
			_test_level()

func _unlock_levels():
	for i in Global.MAX_LEVELS + 1:
		Global.unlocked_levels.append(i)
	level_grid._ready()

func _test_level():
	get_tree().change_scene_to_file("res://content/levels/level_-1.tscn")

func _on_play_button_pressed():
	Global.set_level(max_level_num)

func _on_menu_button_pressed():
	_move_camera(HORIZONTAL_DELTA)

func _on_credits_button_pressed() -> void:
	_move_camera(-VERTICAL_DELTA)

func _on_home_button_pressed():
	# Not great hard coding
	if camera_2d.position.y == -VERTICAL_DELTA.y / 2:
		_move_camera(VERTICAL_DELTA)
	else:
		_move_camera(-HORIZONTAL_DELTA)

func _move_camera(delta: Vector2):
	if block_input:
		return
	block_input = true
	var camera_move_time = _calculate_camera_move_time(delta)
	var target_pos = camera_2d.position + delta
	var tween := get_tree().create_tween()
	timer.start(CAMERA_MOVE_TIME)
	tween.tween_property(
		camera_2d,
		"position",
		target_pos,
		camera_move_time
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _calculate_camera_move_time(delta: Vector2) -> float:
	return (delta.length() / 320) * 1.5

func _on_timer_timeout():
	block_input = false
