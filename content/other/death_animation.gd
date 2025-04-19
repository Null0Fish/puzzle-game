extends Node2D

@onready var texture_rect: TextureRect = $TextureRect

var last_point: float = 1.0
signal finished

func _process(_delta: float) -> void:
	var grad_tex = texture_rect.texture as GradientTexture2D
	var new_gradient = Gradient.new()
	new_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT

	if last_point <= 0.025:
		new_gradient.add_point(0.0, Color("#4f6781"))
		finished.emit()
	else:
		last_point -= 0.025
		new_gradient.add_point(0.0, Color("#00000000"))
		new_gradient.add_point(last_point, Color("#4f6781"))

	grad_tex.gradient = new_gradient
