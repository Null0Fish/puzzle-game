extends Node

@onready var level_grid : GridContainer = $LevelGrid

func _ready():
	for i in level_grid.get_children().size():
		var level_box = level_grid.get_children()[i]
		var level_num = level_box.get_index()
		level_box.set_level(level_num + 1)
		level_box.set_locked(not Global.unlocked_levels.has(level_num))


func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scenes/gui/home_screen.tscn")
