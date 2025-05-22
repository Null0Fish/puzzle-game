extends Node2D

signal fade_finished

@export var level_name: String
@export var show_ui: bool
@export var adjacent_bombs: int
@export var diagonal_bombs: int
@export var full_bombs: int

@onready var root_tile_layer: TileMapLayer = $RootTileLayer
@onready var foreground_layer: TileMapLayer = $RootTileLayer/ForegroundLayer
@onready var hover_layer: TileMapLayer = $RootTileLayer/HoverLayer
@onready var player: CharacterBody2D = $Player
@onready var level_gui: Control = $LevelGUI
@onready var fade: ColorRect = $Fade
@onready var chest: Chest = $Chest
@onready var explosion_audio: AudioStreamPlayer = $ExplosionAudio
@onready var guis: Array = level_gui.get_guis()

const TILE_SIZE = Global.TILE_SIZE
const HOVER_TILE_SOURCE: int = 0
const OBJECT_TILE_SOURCE: int = 1
const LAVA_SPAWNER_ALTAS_TILE_CORDS: Vector2i = Vector2i(2, 2)
const LAVA_ATLAS_TILE_CORDS: Vector2i = Vector2i(0, 2)
const OFFSET: Vector2i = Global.OFFSET

var key_scene: PackedScene = preload("res://content/level_specific/key.tscn")
var upgrade_scene: PackedScene = preload("res://content/level_specific/upgrade.tscn")
var crate_scene: PackedScene = preload("res://content/level_specific/crate.tscn")
var bomb_scene: PackedScene = preload("res://content/other/bomb.tscn")
var lava_scene: PackedScene = preload("res://content/level_specific/lava.tscn")

var allow_hover_atlas_tile_cords: Vector2i = Vector2i(0, 0)
var disallow_hover_atlas_tile_cords: Vector2i = Vector2i(2, 0)
var chest_cell_cords: Vector2i
var bombs_available: Array
var last_placement_time: float
var bomb_list: Array = []
var bomb_locations: Array = []
var crate_list: Array = []
var crate_locations: Array = []
var lava_list: Array = []
var lavaa_locations: Array = []
var is_dragging: bool = false
var should_fade: bool = true

# DEBUG CODE
func _input(event: InputEvent) -> void:
	if Global.debug_enabled:
		if event.is_action_released("debug_skip_level"):
			Global.set_level(Global.get_current_level() + 1)

func _ready():
	_initialize_variables()
	_initialize_effects()
	_initialize_gui()
	_initialize_objects()

func _initialize_variables():
	chest_cell_cords = root_tile_layer.local_to_map(chest.position)
	last_placement_time = 0.0
	level_gui.set_title(level_name)
	level_gui.set_level(str(Global.get_current_level() + 1))
	Global.paused = false
	Global.current_bomb_type = Global.DIAGONAL
	bombs_available = [adjacent_bombs, diagonal_bombs, full_bombs]

func _initialize_effects():
	fade.show()
	Global.try_play_background_music()

func _initialize_gui():
	if not show_ui:
		level_gui.position += Vector2(8,0)
		for gui in guis:
			gui.hide()
	for bomb_type in bombs_available.size():
		guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
		guis[bomb_type].set_type(bomb_type)

func _initialize_objects():
	for cell in foreground_layer.get_used_cells_by_id(OBJECT_TILE_SOURCE):
		var cell_data = foreground_layer.get_cell_tile_data(cell)
		if cell_data.get_custom_data("is_key"):
			var atlas_cords = foreground_layer.get_cell_atlas_coords(cell)
			var key = _initialize_scene_at(cell, key_scene)
			key.init(atlas_cords, foreground_layer)
		if cell_data.get_custom_data("is_upgrade"):
			_initialize_scene_at(cell, upgrade_scene)
		if cell_data.get_custom_data("is_crate"):
			var crate = _initialize_scene_at(cell, crate_scene)
			crate.z_index = 8
			crate_list.append(crate)
		if cell_data.get_custom_data("is_lava"):
			var lava = _initialize_scene_at(cell, lava_scene)
			foreground_layer.set_cell(cell, OBJECT_TILE_SOURCE, LAVA_SPAWNER_ALTAS_TILE_CORDS)
			lava_list.append(lava)

func _initialize_scene_at(cell: Vector2i, scene: PackedScene):
	var new_scene = scene.instantiate()
	add_child(new_scene)
	new_scene.position = _cell_to_cords(cell) + OFFSET
	foreground_layer.set_cell(cell, -1)
	return new_scene

func _cell_to_cords(cell: Vector2i):
	return Vector2i(cell.x * int(TILE_SIZE), cell.y * int(TILE_SIZE))

func _process(_delta):
	_update_fade()
	if Global.paused:
		return
	_update_hover_layer()
	_update_lava()
	_initialize_objects()
	_update_locations()

func _update_fade():
	if should_fade:
		fade.modulate.a -= 0.01
		if fade.modulate.a <= 0:
			should_fade = false
			fade_finished.emit()

func _update_hover_layer():
	hover_layer.clear()
	if is_dragging:
		var cell = root_tile_layer.local_to_map(get_local_mouse_position())
		if _can_place_bomb(cell, Global.current_bomb_type, true):
			_update_hover_layer_tile(allow_hover_atlas_tile_cords)
		else:
			_update_hover_layer_tile(disallow_hover_atlas_tile_cords)

func _update_lava():
	for cell in foreground_layer.get_used_cells_by_id(OBJECT_TILE_SOURCE):
		var cell_data = foreground_layer.get_cell_tile_data(cell)
		if cell_data.get_custom_data("is_lava_spawner"):
			var offsets = [Vector2i(-1, 0), Vector2i(1, 0)]
			for offset in offsets:
				var offset_cell = cell + offset
				if _no_foreground_tile_at_cell(offset_cell):
					foreground_layer.set_cell(offset_cell, 1, LAVA_ATLAS_TILE_CORDS)

func _no_foreground_tile_at_cell(cell: Vector2i):
	return foreground_layer.get_cell_source_id(cell) == -1

func _update_locations():
	bomb_locations = _update_array(bomb_list)
	crate_locations = _update_array(crate_list)
	lavaa_locations = _update_array(lava_list)

func _update_hover_layer_tile(atlas_cords: Vector2i):
	hover_layer.set_cell(hover_layer.local_to_map(get_local_mouse_position()), HOVER_TILE_SOURCE, atlas_cords)

func _update_array(array_1: Array):
	var temp_array = []
	for i in range(array_1.size()):
		temp_array.append(root_tile_layer.local_to_map(array_1[i].position))
	return temp_array

func _pick_up_bomb(index: int):
	bombs_available[bomb_list[index].type] += 1
	guis[bomb_list[index].type].set_bomb_count(bombs_available[bomb_list[index].type])
	_remove_bomb_at(index)

func _place_bomb(cell: Vector2i, bomb_type: int):
	var bomb = bomb_scene.instantiate()
	bomb.position = _cell_to_cords(cell) + OFFSET
	add_child(bomb)
	bomb.init(root_tile_layer, bomb_type)
	bomb.player = player
	bomb.bomb_gui = guis[bomb_type]
	bomb.cell_under_chest = chest_cell_cords + Vector2i(0, 1)
	_add_bomb_to_lists(bomb, cell, bomb_type)

func _detonate_bomb(index: int):
	explosion_audio.pitch_scale = randf_range(0.85, 1.15)
	explosion_audio.play()
	bomb_list[index].detonate(root_tile_layer.local_to_map(player.global_position))
	_remove_bomb_at(index)

func _add_bomb_to_lists(bomb: Bomb, cell: Vector2i, bomb_type: int):
	bomb_list.append(bomb)
	bomb_locations.append(cell)
	bombs_available[bomb_type] -= 1
	guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
	last_placement_time = Time.get_ticks_msec() / 1000.0

func _remove_bomb_at(index: int):
	root_tile_layer.static_objects.erase(bomb_list[index])
	bomb_list[index].remove()
	bomb_locations.remove_at(index)
	bomb_list.remove_at(index)

func _can_place_bomb(cell: Vector2i, bomb_type: int, moving_placed_bomb=false) -> bool:
	# Checks state varibles are valid
	if bombs_available[bomb_type] <= 0 and not moving_placed_bomb:
		return false
	if not player.is_on_floor():
		return false
	if Global.paused:
		return false
	# Check if cell is valid
	if cell in bomb_locations:
		return false
	if cell in crate_locations:
		return false
	if cell in lavaa_locations:
		return false
	if cell in root_tile_layer.get_player_cells():
		return false
	if foreground_layer.get_cell_source_id(cell) != -1:
		return false
	if cell in Global.GUI_CELLS:
		return false
	return true

func _get_all_crate_cells() -> Array:
	var cells = []
	for crate in crate_list:
		cells.append(root_tile_layer.local_to_map(crate.global_position))
	return cells

func _on_death_box_body_entered(body: Node2D) -> void:
	if body is Player:
		body.call_deferred("die")

func try_move_bomb_to(pos: Vector2, bomb: Bomb) -> bool:
	var cell = root_tile_layer.local_to_map(pos)
	var index = bomb_list.find(bomb)
	if _can_place_bomb(cell, bomb.type, true):
		_pick_up_bomb(index)
		_place_bomb(cell, bomb.type)
		return true
	if cell in Global.GUI_CELLS:
		_pick_up_bomb(index)
	return false

func try_pick_up_bomb(cell: Vector2i) -> bool:
	var index = bomb_locations.find(cell)
	if index != -1 and bomb_list[index].is_on_floor():
		_pick_up_bomb(index)
		return true
	return false

func try_detonate_bomb(cell: Vector2i, is_in_laval: bool = false) -> bool:
	_update_locations()
	var index = bomb_locations.find(cell)
	if index != -1 and (bomb_list[index].is_on_floor() or is_in_laval):
		_detonate_bomb(index)
		return true
	return false

func try_place_bomb(cell: Vector2) -> bool:
	cell = root_tile_layer.local_to_map(cell)
	if _can_place_bomb(cell, Global.current_bomb_type):
		_place_bomb(cell, Global.current_bomb_type)
		return true
	return false

func upgrade_bomb_type(bomb_type: int):
	Global.bomb_levels[bomb_type] = Global.bomb_levels[bomb_type] + 1
	guis[bomb_type].upgrade()
