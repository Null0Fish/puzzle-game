extends TileMapLayer

@onready var foreground_layer: TileMapLayer = $ForegroundLayer
@onready var decorative_layer: TileMapLayer = $DecorativeLayer
@onready var static_objects: Array = [$"../Player"]
@onready var player: Player = $"../Player"

const VINE_ATLAS_CORDS: Array = [
	Vector2i(0, 0),
	Vector2i(1, 0)
]

func _process(_delta):
	_destroy_floating_objects()

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
	for cord in VINE_ATLAS_CORDS:
		if cord == decorative_layer.get_cell_atlas_coords(cell):
			return true
	return false

func _is_normal_cell(cell: Vector2i) -> bool:
	return foreground_layer.get_cell_source_id(cell) != -1

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
