extends RigidBody2D

class_name Crate

func _physics_process(_delta):
	rotation = 0
	angular_velocity = 0
	position.x = round(position.x / 8.0) * 8

func _on_area_2d_body_entered(body):
	if body is Player:
		body.call_deferred("die")
