extends Node2D

signal finished

@onready var texture_rect: TextureRect = $TextureRect

const TRANSPARENT_COLOR: Color = Color("#00000000")
const FADE_COLOR: Color = Color("#21181b")

var last_point: float = 1.0

func _process(_delta: float) -> void:
	var grad_tex = texture_rect.texture as GradientTexture2D
	var new_gradient = Gradient.new()
	new_gradient.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT

	if last_point <= 0.025:
		new_gradient.add_point(0.0, FADE_COLOR)
		finished.emit()
	else:
		last_point -= 0.025
		new_gradient.add_point(0.0, TRANSPARENT_COLOR)
		new_gradient.add_point(last_point, FADE_COLOR)

	grad_tex.gradient = new_gradient
