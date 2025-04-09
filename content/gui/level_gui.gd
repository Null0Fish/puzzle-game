extends Control

@onready var level_info: CenterContainer = $LevelInfo
@onready var bomb_gui: Control = $BombGUI

func get_guis():
	return [
		$BombGUI/AdjacentGUI, 
		$BombGUI/DiagonalGUI, 
		$BombGUI/FullGUI
	]

func get_gui_background():
	return $TextureRect

func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")

# temp code
func _on_level_button_pressed():
	get_tree().change_scene_to_file("res://content/gui/start_screen.tscn")

func _on_restart_button_pressed():
	Global.reset()

func _on_question_button_pressed() -> void:
	pass # Replace with function body.

func set_title(text : String):
	level_info.set_title(text)

func set_level(text : String):
	level_info.set_level(text)
