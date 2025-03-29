extends Control

@onready var level_label: Label = $LevelLabel
@onready var level_name: Label = $LevelName
@onready var bomb_gui: Control = $BombGUI

func get_guis():
	return [
		$BombGUI/HBoxContainer/AdjacentGUI, 
		$BombGUI/HBoxContainer/DiagonalGUI, 
		$BombGUI/HBoxContainer/FullGUI
		]

func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")

# temp code
func _on_level_button_pressed():
	get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")

func _on_restart_button_pressed():
	Global.reset()
