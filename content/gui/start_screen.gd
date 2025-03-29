extends Control

@onready var camera_2d: Camera2D = $Camera2D
@onready var label: Label = $TitleUI/PlayButton/Label

const DELTA_POS : int = 320

var max_level_num : int = 0
var max_tutorial_num : int = 0

func _ready():
	for level in Global.unlocked_levels:
		if level > max_level_num:
			max_level_num = level
		label.text = "Resume Game" if max_level_num != 0 else "Start Game"

# Must be deleted sometime nly for testing
func _input(event):
	if event.is_action_released("debug"):
		for i in Global.MAX_LEVELS:
			if not Global.unlocked_levels.has(i):
				Global.unlocked_levels.append(i)
				$MenuUI/LevelGrid._ready()

func _on_play_button_pressed():
	Global.set_level(max_level_num)

func _on_menu_button_pressed():
	move_camera_to(camera_2d.position.x + DELTA_POS)

func _on_settings_button_pressed():
	pass

func _on_home_button_pressed():
	move_camera_to(camera_2d.position.x - DELTA_POS)

func move_camera_to(target_x: float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(camera_2d, "position:x", target_x, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
