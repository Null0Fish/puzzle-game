extends Control

@onready var level_info: CenterContainer = $LevelInfo
@onready var bomb_gui: Control = $BombGUI

func _on_question_button_pressed() -> void:
	pass # Replace with function body.

func get_guis():
	return [
		$BombGUI/AdjacentGUI, 
		$BombGUI/DiagonalGUI, 
		$BombGUI/FullGUI
	]

func get_gui_background():
	return $TextureRect

func set_title(text : String):
	level_info.set_title(text)

func set_level(text : String):
	level_info.set_level(text)
