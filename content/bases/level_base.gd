extends Node2D

@export var level_name: String
@export var show_ui: bool

@onready var hover_layer: TileMapLayer = $GlobalTileMap/HoverLayer
@onready var tile_layers: TileMapLayer = $GlobalTileMap
@onready var foreground: TileMapLayer = $GlobalTileMap/Foreground
@onready var player: CharacterBody2D = $Player
@onready var level_gui: Control = $LevelGUI
@onready var guis: Array = level_gui.get_guis()
@onready var fade: ColorRect = $Fade

const TILE_SIZE = Global.TILE_SIZE
const HOVER_SOURCE: int = 0

var bomb_scene: PackedScene = preload("res://content/other/bomb.tscn")

var allow_hover_cords: Vector2i = Vector2i(0, 0)
var disallow_hover_cords: Vector2i = Vector2i(2, 0)
var bombs_placed: Array = []
var bomb_locations: Array = []
var crates: Array = []
var bombs_available: Array
var last_placement_time: float
var is_dragging: bool

func _ready():
	fade.show()
	_initialize_level()
	_populate_crate_list()

func _initialize_level():
	is_dragging = false
	last_placement_time = 0.0
	level_gui.set_title(level_name)
	level_gui.set_level(str(Global.get_current_level() + 1))
	Global.paused = false
	Global.current_bomb_type = Global.DIAGONAL
	
	var level_gui_background = level_gui.get_gui_background()
	if show_ui:
		level_gui.bomb_gui.show()
		level_gui_background.show()
	else:
		level_gui.bomb_gui.hide()
		level_gui_background.hide()
	
	var level_num = Global.get_current_level()
	bombs_available = Global.get_bombs_available(level_num)
	
	for bomb_type in bombs_available.size():
		guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
		guis[bomb_type].set_type(bomb_type)

func _populate_crate_list():
	for child in get_children():
		if child is Crate:
			crates.append(child)

func _process(_delta):
	hover_layer.clear()
	if is_dragging:
		var cell = tile_layers.local_to_map(get_local_mouse_position())
		if _can_place_bomb(cell, Global.current_bomb_type):
			_update_hover_layer(allow_hover_cords)
		else:
			_update_hover_layer(disallow_hover_cords)
	fade.modulate.a -= 0.01
	_update_bomb_locations()

func _update_hover_layer(atlas_cords: Vector2i):
	hover_layer.set_cell(hover_layer.local_to_map(get_local_mouse_position()), HOVER_SOURCE, atlas_cords)

func _update_bomb_locations():
	for i in range(bombs_placed.size()):
		bomb_locations[i] = tile_layers.local_to_map(bombs_placed[i].position)

func upgrade_bomb_type(bomb_type: int):
	guis[bomb_type].upgrade()

func _pick_up_bomb(index: int):
	bombs_available[bombs_placed[index].type] += 1
	guis[bombs_placed[index].type].set_bomb_count(bombs_available[bombs_placed[index].type])
	_remove_bomb_at(index)

func _place_bomb(cell: Vector2i, bomb_type: int):
	var bomb = bomb_scene.instantiate()
	bomb.position = Vector2(cell.x * TILE_SIZE + TILE_SIZE / 2, cell.y * TILE_SIZE + TILE_SIZE / 2)
	add_child(bomb)
	bomb.init(tile_layers, bomb_type)
	_add_bomb_to_lists(bomb, cell, bomb_type)

func _detonate_bomb(index: int):
	if bombs_placed[index].is_on_floor():
		bombs_placed[index].detonate(tile_layers.local_to_map(player.global_position))
		_remove_bomb_at(index)

func _add_bomb_to_lists(bomb: Bomb, cell: Vector2i, bomb_type: int):
	bombs_placed.append(bomb)
	bomb_locations.append(cell)
	bombs_available[bomb_type] -= 1
	guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
	last_placement_time = Time.get_ticks_msec() / 1000.0

func _remove_bomb_at(index: int):
	tile_layers.static_objects.erase(bombs_placed[index])
	bombs_placed[index].remove()
	bomb_locations.remove_at(index)
	bombs_placed.remove_at(index)

func _can_place_bomb(cell: Vector2i, bomb_type: int) -> bool:
	if bombs_available[bomb_type] <= 0:
		return false
	if cell in bomb_locations:
		return false
	if not player.is_on_floor():
		return false
	if cell in tile_layers.get_player_cells():
		return false
	if foreground.get_cell_source_id(cell) != -1:
		return false
	if cell in Global.GUI_CELLS:
		return false
	if cell in _get_all_crate_cells():
		return false
	return true

func _get_all_crate_cells() -> Array:
	var cells = []
	for crate in crates:
		cells.append(tile_layers.local_to_map(crate.global_position))
	return cells

func _on_death_box_body_entered(body: Node2D) -> void:
	if body is Player:
		body.call_deferred("die")

func try_pick_up_bomb(cell: Vector2i):
	var index = bomb_locations.find(cell)
	if index != -1:
		_pick_up_bomb(index)

func try_detonate_bomb(cell: Vector2i):
	var index = bomb_locations.find(cell)
	if index != -1:
		_detonate_bomb(index)

func try_place_bomb(cell: Vector2):
	cell = tile_layers.local_to_map(cell)
	if _can_place_bomb(cell, Global.current_bomb_type):
		_place_bomb(cell, Global.current_bomb_type)
