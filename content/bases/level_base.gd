extends Node2D

@export var level_name: String
@export var show_ui: bool

@onready var root_tile_layer: TileMapLayer = $RootTileLayer
@onready var foreground_layer: TileMapLayer = $RootTileLayer/ForegroundLayer
@onready var hover_layer: TileMapLayer = $RootTileLayer/HoverLayer
@onready var player: CharacterBody2D = $Player
@onready var level_gui: Control = $LevelGUI
@onready var guis: Array = level_gui.get_guis()
@onready var fade: ColorRect = $Fade
@onready var explosion_player: AudioStreamPlayer = $ExplosionPlayer

const TILE_SIZE = Global.TILE_SIZE
const HOVER_SOURCE: int = 0
const OFFSET: Vector2i = Global.OFFSET

var key_scene: PackedScene = preload("res://content/level_specific/key.tscn")
var upgrade_scene: PackedScene = preload("res://content/level_specific/upgrade.tscn")
var crate_scene: PackedScene = preload("res://content/level_specific/crate.tscn")
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
	# Initialize variables
	is_dragging = false
	last_placement_time = 0.0
	level_gui.set_title(level_name)
	level_gui.set_level(str(Global.get_current_level() + 1))
	Global.paused = false
	Global.current_bomb_type = Global.DIAGONAL
	bombs_available = Global.get_bombs_available(Global.get_current_level())
	
	# Initialize GUI
	var level_gui_background = level_gui.get_gui_background()
	if show_ui:
		level_gui.bomb_gui.show()
		level_gui_background.show()
	else:
		level_gui.bomb_gui.hide()
		level_gui_background.hide()
	for bomb_type in bombs_available.size():
		guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
		guis[bomb_type].set_type(bomb_type)
	
	# Initialize level objects
	for cell in foreground_layer.get_used_cells_by_id(1):
		var cell_data = foreground_layer.get_cell_tile_data(cell)
		if cell_data.get_custom_data("is_key"):
			var atlas_cords = foreground_layer.get_cell_atlas_coords(cell)
			var key = _initialize_scene_at(cell, key_scene)
			key.init(atlas_cords, foreground_layer)
		if cell_data.get_custom_data("is_upgrade"):
			_initialize_scene_at(cell, upgrade_scene)
		if cell_data.get_custom_data("is_crate"):
			_initialize_scene_at(cell, crate_scene)

func _initialize_scene_at(cell: Vector2i, scene: PackedScene): 
	var new_scene = scene.instantiate()
	add_child(new_scene)
	new_scene.position = _cell_to_cords(cell) + OFFSET
	foreground_layer.set_cell(cell, -1)
	return new_scene

func _cell_to_cords(cell: Vector2i):
	return Vector2i(cell.x * int(TILE_SIZE), cell.y * int(TILE_SIZE))

func _populate_crate_list():
	for child in get_children():
		if child is Crate:
			crates.append(child)

func _process(_delta):
	hover_layer.clear()
	if is_dragging:
		var cell = root_tile_layer.local_to_map(get_local_mouse_position())
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
		bomb_locations[i] = root_tile_layer.local_to_map(bombs_placed[i].position)

func upgrade_bomb_type(bomb_type: int):
	guis[bomb_type].upgrade()

func _pick_up_bomb(index: int):
	bombs_available[bombs_placed[index].type] += 1
	guis[bombs_placed[index].type].set_bomb_count(bombs_available[bombs_placed[index].type])
	_remove_bomb_at(index)

func _place_bomb(cell: Vector2i, bomb_type: int):
	var bomb = bomb_scene.instantiate()
	bomb.position = _cell_to_cords(cell) + OFFSET
	add_child(bomb)
	bomb.init(root_tile_layer, bomb_type)
	_add_bomb_to_lists(bomb, cell, bomb_type)

func _detonate_bomb(index: int):
	explosion_player.play()
	bombs_placed[index].detonate(root_tile_layer.local_to_map(player.global_position))
	_remove_bomb_at(index)

func _add_bomb_to_lists(bomb: Bomb, cell: Vector2i, bomb_type: int):
	bombs_placed.append(bomb)
	bomb_locations.append(cell)
	bombs_available[bomb_type] -= 1
	guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
	last_placement_time = Time.get_ticks_msec() / 1000.0

func _remove_bomb_at(index: int):
	root_tile_layer.static_objects.erase(bombs_placed[index])
	bombs_placed[index].remove()
	bomb_locations.remove_at(index)
	bombs_placed.remove_at(index)

func _can_place_bomb(cell: Vector2i, bomb_type: int) -> bool:
	# Checks bomb count of type
	if bombs_available[bomb_type] <= 0:
		return false
	# Checks cell for static object
	if cell in bomb_locations or cell in _get_all_crate_cells():
		return false
	# Checks for static tiles
	if foreground_layer.get_cell_source_id(cell) != -1:
		return false
	# Checks player data
	if not player.is_on_floor() or cell in root_tile_layer.get_player_cells():
		return false
	# Prevent destorying the hidden GUI cells
	if cell in Global.GUI_CELLS:
		return false
	return true

func _get_all_crate_cells() -> Array:
	var cells = []
	for crate in crates:
		cells.append(root_tile_layer.local_to_map(crate.global_position))
	return cells

func _on_death_box_body_entered(body: Node2D) -> void:
	if body is Player:
		body.call_deferred("die")

func try_pick_up_bomb(cell: Vector2i):
	var index = bomb_locations.find(cell)
	if index != -1 and bombs_placed[index].is_on_floor():
		_pick_up_bomb(index)

func try_detonate_bomb(cell: Vector2i):
	var index = bomb_locations.find(cell)
	if index != -1:
		_detonate_bomb(index)

func try_place_bomb(cell: Vector2):
	cell = root_tile_layer.local_to_map(cell)
	if _can_place_bomb(cell, Global.current_bomb_type):
		_place_bomb(cell, Global.current_bomb_type)
