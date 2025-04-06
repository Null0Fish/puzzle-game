extends Control

@onready var camera_2d: Camera2D = $Camera2D
@onready var label: Label = $TitleUI/PlayButton/Label
@onready var timer: Timer = $Timer

const DELTA_POS: int = 320
const CAMERA_MOVE_TIME: float = 1.5

var max_level_num: int = 0
var block_input: bool = false

func _ready():
	_initialize_menu()

func _initialize_menu():
	for level in Global.unlocked_levels:
		max_level_num = max(max_level_num, level)
	label.text = "Resume Game" if max_level_num != 0 else "Start Game"

func _input(event):
	_handle_debug_input(event)
	_handle_test_input(event)

func _handle_debug_input(event):
	if event.is_action_released("debug"):
		for i in Global.MAX_LEVELS:
			Global.unlocked_levels.append(i)
		$MenuUI/LevelGrid._ready()

func _handle_test_input(event):
	if event.is_action_released("test"):
		get_tree().change_scene_to_file("res://content/levels/level_3.tscn")

func _on_play_button_pressed():
	Global.set_level(max_level_num)

func _on_menu_button_pressed():
	_move_camera(DELTA_POS)

func _on_home_button_pressed():
	_move_camera(-DELTA_POS)

func _move_camera(offset: float):
	if block_input:
		return
	block_input = true
	timer.start(CAMERA_MOVE_TIME)
	
	var target_x = camera_2d.position.x + offset
	var tween := get_tree().create_tween()
	tween.tween_property(camera_2d, "position:x", target_x, CAMERA_MOVE_TIME).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_timer_timeout():
	block_input = false
