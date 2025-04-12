extends TileMapLayer

@onready var foreground_layer: TileMapLayer = $ForegroundLayer
@onready var decorative_layer: TileMapLayer = $DecorativeLayer
@onready var ore_layer: TileMapLayer = $OreLayer
@onready var static_objects: Array = [$"../Player"]
@onready var player: Player = $"../Player"

const VINE_ATLAS: Vector2i = Vector2i(4, 0)
const KEY_SET_ID: int = 4

func _process(_delta):
	_destroy_floating_objects()
	_check_static_object_collisions()

func _check_static_object_collisions():
	for object in static_objects:
		var object_cell = local_to_map(object.global_position)
		if _is_on_cell_type("Lava", object_cell):
			object.die()
		elif object is Player and _is_on_cell_type("Key", object_cell):
			_handle_key_collision(object_cell)

func _handle_key_collision(object_cell: Vector2i):
	var key_coord = foreground_layer.get_cell_atlas_coords(object_cell)
	var lock_atlas_coords = key_coord + Vector2i(0, 1)
	for cell in foreground_layer.get_used_cells():
		if foreground_layer.get_cell_atlas_coords(cell) == lock_atlas_coords \
		and foreground_layer.get_cell_source_id(cell) == KEY_SET_ID:
			foreground_layer.set_cell(cell, -1)
	foreground_layer.set_cell(object_cell, -1)

func _destroy_floating_objects():
	for cell in decorative_layer.get_used_cells():
		var cell_below = cell + Vector2i(0, 1)
		var cell_above = cell + Vector2i(0, -1)
		if _is_vine(cell):
			if not _is_vine(cell_above) and not _is_normal_cell(cell_above):
				decorative_layer.set_cell(cell, -1)
		elif not _is_normal_cell(cell_below):
			decorative_layer.set_cell(cell, -1)


func _is_vine(cell: Vector2i) -> bool:
	return decorative_layer.get_cell_atlas_coords(cell) == VINE_ATLAS

func _is_normal_cell(cell: Vector2i) -> bool:
	return foreground_layer.get_cell_source_id(cell) != -1

func _is_on_cell_type(type: String, cell: Vector2i) -> bool:
	var cell_data = foreground_layer.get_cell_tile_data(cell)
	return cell_data and cell_data.get_custom_data(type)

func get_near_cells(object) -> Array:
	var cells = []
	var pos = object.global_position
	var cell = local_to_map(pos)
	cells.append(cell)
	cells.append(local_to_map(cell + Vector2i(Global.TILE_SIZE / 2 - 1, 0)))
	cells.append(local_to_map(cell - Vector2i(Global.TILE_SIZE / 2 - 1, 0)))
	return cells

func get_player_cells() -> Array:
	var player_cells = []
	var player_pos = player.global_position
	var player_cell = local_to_map(player_pos)
	player_cells.append(player_cell)
	player_cells.append(local_to_map(player_pos + Vector2(Global.PLAYER_SIZE / 2, 0)))
	player_cells.append(local_to_map(player_pos - Vector2(Global.PLAYER_SIZE / 2, 0)))
	return player_cells
