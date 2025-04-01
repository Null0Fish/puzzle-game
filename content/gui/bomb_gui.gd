extends Control

@onready var sprite: Sprite2D = $BombIcon
@onready var bomb_count: Label = $BombCount
@onready var panel: Panel = $Panel

const TILE_SIZE = Global.TILE_SIZE

var type: int
var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()

var dragging: bool = false
var ghost_bomb: Sprite2D = null

func _process(_delta):
	_update_panel_style()
	if dragging:
		sprite.modulate.a = .75
		if ghost_bomb:
			ghost_bomb.global_position = get_global_mouse_position()
	else:
		sprite.modulate.a = 1

func _update_panel_style():
	if Global.current_bomb_type == type:
		style_box_flat.bg_color = Color(0.130728, 0.159803, 0.357762)
	else:
		style_box_flat.bg_color = Color(0.133, 0.125, 0.204)
	panel.add_theme_stylebox_override("panel", style_box_flat)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if _is_mouse_over_bomb(event.position):
					dragging = true
					Global.current_bomb_type = type
					_create_ghost_bomb()
			else:
				if dragging:
					dragging = false
					if ghost_bomb:
						ghost_bomb.queue_free()
						ghost_bomb = null
					get_tree().get_current_scene().try_place_bomb(get_global_mouse_position())

func _is_mouse_over_bomb(mouse_position: Vector2) -> bool:
	return panel.get_rect().has_point(mouse_position)

func _create_ghost_bomb():
	ghost_bomb = Sprite2D.new()
	ghost_bomb.texture = sprite.texture
	ghost_bomb.global_position = get_global_mouse_position()
	ghost_bomb.region_enabled = true
	ghost_bomb.region_rect = sprite.region_rect
	ghost_bomb.z_index = 7
	get_tree().get_current_scene().add_child(ghost_bomb)

func upgrade():
	var rect_pos = sprite.region_rect.position
	var new_rect = Rect2i(Vector2i(rect_pos.x - TILE_SIZE, rect_pos.y), Vector2i(TILE_SIZE, TILE_SIZE))
	sprite.region_rect = new_rect

func set_type(bomb_type: int):
	type = bomb_type
	var rect = Rect2(Vector2(TILE_SIZE * 2, TILE_SIZE * type), Vector2(TILE_SIZE, TILE_SIZE))
	sprite.region_rect = rect

func set_bomb_count(val: int):
	bomb_count.text = str(val)
