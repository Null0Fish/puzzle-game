extends Control

@onready var content: Control = null
@onready var panel: Panel = $CenterContainer/Panel

const ACTIVE_COLOR: Color = Global.ACTIVE_COLOR
const INACTIVE_COLOR: Color = Global.INACTIVE_COLOR
const BAD_CODE: int = -1

var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
var is_active_panel: bool = false
var local_pause: bool = false

func update_panel_style():
	if is_active_panel:
		content.show()
		style_box_flat.bg_color = ACTIVE_COLOR
	else:
		content.hide()
		style_box_flat.bg_color = INACTIVE_COLOR
	panel.add_theme_stylebox_override("panel", style_box_flat)


func _on_question_button_pressed() -> void:
	is_active_panel = !is_active_panel
	if Global.paused == local_pause:
		Global.paused = !Global.paused
		local_pause = !local_pause
		update_panel_style()
		Global.question_mark_override = !Global.question_mark_override
