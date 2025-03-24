extends Node2D

func get_guis():
	return [$AdjacentGUI, $DiagonalGUI, $FullGUI]

func _on_home_button_pressed():
	get_tree().change_scene_to_file("res://scenes/gui/home_screen.tscn")

func _on_level_button_pressed():
	get_tree().change_scene_to_file("res://scenes/gui/level_menu.tscn")

func _on_restart_button_pressed():
	Global.reset()
