extends Control

const TILE_SIZE = Global.TILE_SIZE

@onready var sprite: Sprite2D = $BombIcon
@onready var bomb_count: Label = $BombCount
@onready var panel: Panel = $Panel

var type: int
var style_box_flat: StyleBoxFlat = StyleBoxFlat.new()

func _process(_delta):
	_update_panel_style()

func _update_panel_style():
	if Global.current_bomb_type == type:
		style_box_flat.bg_color = Color(0.130728, 0.159803, 0.357762)
	else:
		style_box_flat.bg_color = Color(0.133, 0.125, 0.204)
	panel.add_theme_stylebox_override("panel", style_box_flat)

func set_type(bomb_type: int):
	type = bomb_type
	var rect = Rect2(Vector2(TILE_SIZE * 2, TILE_SIZE * type), Vector2(TILE_SIZE, TILE_SIZE))
	sprite.region_rect = rect

func set_bomb_count(val: int):
	bomb_count.text = str(val)

func _on_panel_gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		Global.current_bomb_type = type

func upgrade():
	var rect_pos = sprite.region_rect.position
	var new_rect = Rect2i(Vector2i(rect_pos.x - TILE_SIZE, rect_pos.y), Vector2i(TILE_SIZE, TILE_SIZE))
	sprite.region_rect = new_rect
