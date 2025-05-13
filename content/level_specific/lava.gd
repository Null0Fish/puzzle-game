extends Node2D

@onready var sprite_2d := $Sprite2D
var shader_material: ShaderMaterial

func _ready() -> void:
	shader_material = sprite_2d.material as ShaderMaterial
	update_lava_tint()

func _process(_delta: float) -> void:
	update_lava_tint()

func update_lava_tint() -> void:
	if shader_material:
		shader_material.set("shader_parameter/lava_tint", Global.lava_tint)

func _on_bomb_death_area_body_entered(body: Node2D) -> void:
	if body is Bomb:
		body.call_deferred("die")

func _on_player_death_area_body_entered(body: Node2D) -> void:
	if body is Player:
		body.call_deferred("die")
