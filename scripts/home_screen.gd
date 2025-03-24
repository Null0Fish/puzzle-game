extends Node

@onready var label: Label = $PlayButton/Label

var max_level_num : int = 0
var max_tutorial_num : int = 0

func _ready():
	for level in Global.unlocked_levels:
		if level > max_level_num:
			max_level_num = level
		label.text = "Resume Game" if max_level_num != 0 else "Start Game"

func _on_play_button_pressed():
	Global.set_level(max_level_num)

func _on_menu_button_pressed():
	get_tree().change_scene_to_file("res://scenes/gui/level_menu.tscn")

func _on_settings_button_pressed():
	print("Settings button pressed!")

# Must be deleted sometime nly for testing
func _input(event):
	if event.is_action_released("debug"):
		for i in Global.MAX_LEVELS:
			if not Global.unlocked_levels.has(i):
				Global.unlocked_levels.append(i)
