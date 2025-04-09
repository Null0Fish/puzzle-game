extends Control

@onready var label: Label = $Label
@onready var panel: Panel = $CenterContainer/Panel

var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
var is_active_panel: bool = false

func _process(_delta: float) -> void:
	_update_panel_style()

func _update_panel_style():
	if is_active_panel:
		label.show()
		style_box_flat.bg_color = Color(0.130728, 0.159803, 0.357762)
	else:
		label.hide()
		style_box_flat.bg_color = Color(0.133, 0.125, 0.204)
	panel.add_theme_stylebox_override("panel", style_box_flat)


func _on_question_button_pressed() -> void:
	is_active_panel = not is_active_panel
	_update_panel_style()
