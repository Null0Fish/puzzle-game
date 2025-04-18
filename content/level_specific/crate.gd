extends RigidBody2D

class_name Crate

func _physics_process(_delta):
	rotation = 0
	angular_velocity = 0
	position.x = round(position.x)


func _on_area_2d_body_entered(body):
	if body is Player:
		print("crate crush :(")
		Global.call_deferred("restart")
