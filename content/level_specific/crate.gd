extends RigidBody2D

class_name Crate

func _on_area_2d_body_entered(body):
	if body is Player:
		Global.call_deferred("restart")
