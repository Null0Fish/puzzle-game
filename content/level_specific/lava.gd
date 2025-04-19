extends Node2D

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.call_deferred("die")
	if body is Bomb:
		body.call_deferred("die")
	if body is Crate:
		pass
