extends TileMapLayer

const VINE_ATLAS = Vector2i(4, 0)
const KEY_SET_ID = 4

@onready var background: TileMapLayer = $Background
@onready var foreground: TileMapLayer = $Foreground
@onready var ores: TileMapLayer = $Ores
@onready var extras: TileMapLayer = $Extras
@onready var warning: TileMapLayer = $Warning

@onready var static_objects : Array = [$"../Player"]
@onready var player : Player = $"../Player"

func _process(_delta):
	clear_warnings() 
	destroy_floating_objects()
	for object in static_objects:
		var object_cell = local_to_map(object.global_position)
		if is_on_cell_type("Lava", object_cell):
			object.die()
		elif object is Player and is_on_cell_type("Key", object_cell):
			var key_coord = foreground.get_cell_atlas_coords(object_cell)
			var lock_atlas_coords = key_coord + Vector2i(0, 1)
			for cell in foreground.get_used_cells():
				if foreground.get_cell_atlas_coords(cell) == lock_atlas_coords \
				and foreground.get_cell_source_id(cell) == KEY_SET_ID:
					foreground.set_cell(cell, -1)
			foreground.set_cell(object_cell, -1)

func destroy_floating_objects():
	var used_cells = extras.get_used_cells()
	for cell in used_cells:
		var cell_below = cell + Vector2i(0, 1)
		var cell_above = cell + Vector2i(0, -1)
		if is_vine(cell):
			if not is_vine(cell_above) and not is_normal_cell(cell_above):
				extras.set_cell(cell, -1)
		elif not is_normal_cell(cell_below):
			extras.set_cell(cell, -1)

func clear_warnings():
	for warning_cell in warning.get_used_cells():
		warning.set_cell(warning_cell, -1)

func is_vine(cell: Vector2i) -> bool:
	return extras.get_cell_atlas_coords(cell) == VINE_ATLAS

func is_normal_cell(cell: Vector2i) -> bool:
	return foreground.get_cell_source_id(cell) != -1

func is_on_cell_type(type: String, cell: Vector2i) -> bool:
	var cell_data = foreground.get_cell_tile_data(cell)
	return cell_data and cell_data.get_custom_data(type)

func get_near_cells(object):
	var cells = []
	var pos = object.global_position
	var cell = local_to_map(pos)
	cells.append(cell)
	cells.append(local_to_map(cell + Vector2i(Global.TILE_SIZE / 2 - 1, 0)))
	cells.append(local_to_map(cell - Vector2i(Global.TILE_SIZE / 2 - 1, 0)))
	return cells
	
func get_player_cells():
	var player_cells = []
	var player_pos = player.global_position
	var player_cell = local_to_map(player_pos)
	player_cells.append(player_cell)
	player_cells.append(local_to_map(player_pos + Vector2(Global.PLAYER_SIZE / 2, 0)))
	player_cells.append(local_to_map(player_pos - Vector2(Global.PLAYER_SIZE / 2, 0)))
	return player_cells
	


func _on_warning_hidden() -> void:
	pass # Replace with function body.


func _on_extras_property_list_changed() -> void:
	pass # Replace with function body.
