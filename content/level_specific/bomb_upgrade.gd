extends Node2D

func _on_area_2d_body_entered(body):
	if body is Player:
		var current_bomb_type = Global.current_bomb_type
		var current_bomb_level = Global.bomb_levels[current_bomb_type]
		if current_bomb_level < Global.MAX_BOMB_LEVEL:
			get_tree().current_scene.upgrade_bomb_type(current_bomb_type)
			queue_free()
			Global.bomb_levels[current_bomb_type] = Global.bomb_levels[current_bomb_type] + 1
