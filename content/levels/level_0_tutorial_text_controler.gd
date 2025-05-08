extends Node

@onready var second_tutorial_text: Label = $SecondTutorialText
@onready var first_tutorial_text: Label = $FirstTutorialText

func _ready() -> void:
	first_tutorial_text.show()
	second_tutorial_text.hide()

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump"):
		first_tutorial_text.hide()
		second_tutorial_text.show()
