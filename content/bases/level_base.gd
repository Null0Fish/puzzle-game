extends Node2D

const TILE_SIZE = Global.TILE_SIZE

@export var level_name: String
@export var show_ui: bool

@onready var tilemap: TileMapLayer = $GlobalTileMap
@onready var foreground: TileMapLayer = $GlobalTileMap/Foreground
@onready var player: CharacterBody2D = $Player
@onready var level_gui: Control = $LevelGUI
@onready var guis: Array = level_gui.get_guis()

var bomb_scene: PackedScene = preload("res://content/level_specific/bomb.tscn")

var bombs_placed: Array = []
var bomb_locations: Array = []
var crates: Array = []
var bombs_available: Array

func _ready():
	_initialize_level()
	_populate_crate_list()

func _initialize_level():
	level_gui.set_name(level_name)
	level_gui.set_level(str(Global.get_current_level() + 1))
	Global.paused = false
	Global.current_bomb_type = Global.DIAGONAL
	
	if show_ui:
		level_gui.bomb_gui.show()
	else:
		level_gui.bomb_gui.hide()
	
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
	for i in range(bombs_placed.size()):
		bomb_locations[i] = tilemap.local_to_map(bombs_placed[i].position)

func upgrade_bomb_type(bomb_type: int):
	guis[bomb_type].upgrade()

func handle_left_click(cell: Vector2i):
	if can_place_bomb(cell, Global.current_bomb_type):
		place_bomb(cell, Global.current_bomb_type)
	elif cell in bomb_locations:
		_remove_bomb(cell)

func handle_right_click(cell: Vector2i):
	var index = bomb_locations.find(cell)
	if index != -1:
		detonate_bomb(bombs_placed[index])

func place_bomb(cell: Vector2i, bomb_type: int):
	var bomb = bomb_scene.instantiate()
	bomb.position = Vector2(cell.x * TILE_SIZE + TILE_SIZE / 2, cell.y * TILE_SIZE + TILE_SIZE / 2)
	add_child(bomb)
	bomb.init(tilemap, bomb_type)
	
	bombs_placed.append(bomb)
	bomb_locations.append(cell)
	bombs_available[bomb_type] -= 1
	guis[bomb_type].set_bomb_count(bombs_available[bomb_type])

func detonate_bomb(bomb: Bomb):
	var index = bombs_placed.find(bomb)
	if index != -1:
		bomb.detonate(tilemap.local_to_map(player.global_position))
		bombs_placed.remove_at(index)
		bomb_locations.remove_at(index)

func _remove_bomb(cell: Vector2i):
	var index = bomb_locations.find(cell)
	if index != -1:
		var bomb = bombs_placed[index]
		bomb_locations.remove_at(index)
		bombs_placed.remove_at(index)
		bombs_available[bomb.type] += 1
		tilemap.static_objects.erase(bomb)
		bomb.queue_free()
		guis[bomb.type].set_bomb_count(bombs_available[bomb.type])

func get_all_crate_cells() -> Array:
	var cells = []
	for crate in crates:
		cells.append_array(tilemap.get_near_cells(crate))
	return cells

func can_place_bomb(cell: Vector2i, bomb_type: int) -> bool:
	if bombs_available[bomb_type] <= 0:
		return false
	if cell in bomb_locations:
		return false
	if not player.is_on_floor():
		return false
	if cell in tilemap.get_player_cells():
		return false
	if foreground.get_cell_source_id(cell) != -1:
		return false
	for crate_cells in get_all_crate_cells():
		if cell in crate_cells:
			return false
	return true

func _on_area_2d_body_entered(body):
	if body is Player:
		body.call_deferred("die")
