extends Control

@onready var level_info: CenterContainer = $LevelInfo
@onready var bomb_gui: Control = $BombGUI
@onready var question_gui: Control = $BombGUI/QuestionGUI
@onready var input_info_gui: Control = $InputInfoGUI

func _ready() -> void:
	question_gui.content = input_info_gui
	question_gui.update_panel_style()

func get_guis():
	return [
		$BombGUI/AdjacentGUI,
		$BombGUI/DiagonalGUI,
		$BombGUI/FullGUI
	]

func set_title(text : String):
	level_info.set_title(text)

func set_level(text : String):
	level_info.set_level(text)
