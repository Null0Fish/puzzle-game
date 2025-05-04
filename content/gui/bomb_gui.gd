extends Control

@onready var bomb_count: Label = $BombCount
@onready var panel: Panel = $Panel
@onready var tooltip_label: Label = $TooltipLabel
@onready var ghost_bomb: Sprite2D = $GhostBomb
@onready var bomb_icon: Sprite2D = $BombIcon

const TILE_SIZE = int(Global.TILE_SIZE)
const OFFSET = Global.OFFSET
const ACTIVE_COLOR: Color = Global.ACTIVE_COLOR
const INACTIVE_COLOR: Color = Global.INACTIVE_COLOR

var type: int
var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()
var dragging: bool = false
var tween: Tween = null

func _process(_delta):
	_update_panel_style()
	if Global.paused:
		return

	ghost_bomb.texture = bomb_icon.texture
	ghost_bomb.region_enabled = true
	ghost_bomb.region_rect = bomb_icon.region_rect

	if panel.get_rect().has_point(panel.get_local_mouse_position()):
		tooltip_label.text = Global.type_to_string(type)
		tooltip_label.visible = true
	else:
		tooltip_label.visible = false

	if dragging:
		bomb_icon.modulate.a = 0.5
		ghost_bomb.show()
	else:
		ghost_bomb.hide()
		bomb_icon.modulate.a = 1


func _move_ghost_bomb(target_position: Vector2):
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(ghost_bomb, "global_position", target_position, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _update_panel_style():
	if Global.current_bomb_type == type and not Global.question_mark_override:
		style_box_flat.bg_color = ACTIVE_COLOR
	else:
		style_box_flat.bg_color = INACTIVE_COLOR
	panel.add_theme_stylebox_override("panel", style_box_flat)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_mouse_over_bomb(event.position):
					dragging = true
					_scene_root().is_dragging = true
					Global.current_bomb_type = type
			else:
				if dragging:
					dragging = false
					_scene_root().is_dragging = false
					_scene_root().try_place_bomb(get_global_mouse_position())

func _is_mouse_over_bomb(mouse_position: Vector2) -> bool:
	return panel.get_rect().has_point(mouse_position)

func _scene_root():
	return get_tree().get_current_scene()

func upgrade():
	var rect_pos = bomb_icon.region_rect.position
	var new_rect = Rect2i(Vector2i(rect_pos.x - TILE_SIZE, rect_pos.y), Vector2i(TILE_SIZE, TILE_SIZE))
	bomb_icon.region_rect = new_rect
	return bomb_icon.region_rect

func set_type(bomb_type: int):
	type = bomb_type
	var rect = Rect2(Vector2(TILE_SIZE * 2, TILE_SIZE * type), Vector2(TILE_SIZE, TILE_SIZE))
	bomb_icon.region_rect = rect

func set_bomb_count(val: int):
	bomb_count.text = str(val)
