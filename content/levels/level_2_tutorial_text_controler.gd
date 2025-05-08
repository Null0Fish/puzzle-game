extends Node

@onready var first_tutorial_text: Label = $FirstTutorialText
@onready var second_tutorial_text: Label = $SecondTutorialText
@onready var third_tutorial_texxt: Label = $ThirdTutorialTexxt
@onready var fourth_turotial_text: Label = $FourthTurotialText
@onready var level_2: Node2D = $".."

var has_placed_bomb : bool = false

func _ready() -> void:
	second_tutorial_text.hide()
	third_tutorial_texxt.hide()
	fourth_turotial_text.hide()

func _process(_delta: float) -> void:
	if level_2.bomb_locations.size() != 0 and not has_placed_bomb:
		has_placed_bomb = true
		first_tutorial_text.hide()
		second_tutorial_text.show()
	if has_placed_bomb and level_2.bomb_locations.size() == 0:
		second_tutorial_text.hide()
		third_tutorial_texxt.show()
		fourth_turotial_text.show()
