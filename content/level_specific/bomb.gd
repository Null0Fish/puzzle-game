extends RigidBody2D

class_name Bomb

const ADJACENT: int = Global.ADJACENT
const DIAGONAL: int = Global.DIAGONAL
const FULL: int = Global.FULL
const WARNING_TILE_ATLAS: Vector2i = Vector2i(0, 0)
const WARNING_ID: int = 3
const BOMB_TEXTURES: Dictionary = {
	ADJACENT: preload("res://assets/bombs/adjacent_bomb.png"),
	DIAGONAL: preload("res://assets/bombs/diagonal_bomb.png"),
	FULL: preload("res://assets/bombs/full_bomb.png")
}

@onready var bomb_sprite: Sprite2D = $BombSprite 
@onready var raycast: RayCast2D = $RayCast2D

var tilemap: TileMapLayer
var type: int
var cells_to_detonate: Array = []

func init(map: TileMapLayer, variant: int):
	tilemap = map
	type = variant
	bomb_sprite.texture = BOMB_TEXTURES[type]
	tilemap.static_objects.append(self)

func _process(_delta):
	_detect_player_collision()
	_update_warning_cells()

func _detect_player_collision():
	if raycast.is_colliding() and raycast.get_collider() is Player:
		Global.reset()

func _update_warning_cells():
	cells_to_detonate = _get_cells_to_detonate(tilemap.local_to_map(global_position))
	for cell in cells_to_detonate:
		if tilemap.warning.get_cell_source_id(cell) != -1:
			var atlas_pos = tilemap.warning.get_cell_atlas_coords(cell)
			if atlas_pos != Vector2i(0, 2):
				tilemap.warning.set_cell(cell, WARNING_ID, atlas_pos + Vector2i(1, 0))
			else:
				print("Not enough bomb warning tiles in atlas!")
		else:
			tilemap.warning.set_cell(cell, WARNING_ID, WARNING_TILE_ATLAS)

func is_on_floor() -> bool:
	return raycast.is_colliding() and (raycast.get_collider() is TileMap or raycast.get_collider() is RigidBody2D)

func detonate(player_cell: Vector2i):
	tilemap.static_objects.erase(self)
	for cell in cells_to_detonate:
		if cell == player_cell:
			Global.reset()
		tilemap.warning.set_cell(cell, -1)
		var cell_data = tilemap.foreground.get_cell_tile_data(cell)
		if cell_data and cell_data.get_custom_data("Breakable"):
			tilemap.foreground.set_cell(cell, -1)
			_update_surrounding(cell)
		tilemap.ores.set_cell(cell, -1)
	queue_free()

func _get_cells_to_detonate(cell: Vector2i) -> Array:
	var bomb_level = Global.bomb_levels[type]
	var cells = []
	for y in range(cell.y - bomb_level - 1, cell.y + bomb_level + 2):
		for x in range(cell.x - bomb_level - 1, cell.x + bomb_level + 2):
			if cell.x != x or cell.y != y:
				if type == DIAGONAL or type == FULL:
					if abs(x - cell.x) == abs(y - cell.y):
						cells.append(Vector2i(x, y))
				if type == ADJACENT or type == FULL:
					if x == cell.x or y == cell.y:
						cells.append(Vector2i(x, y))
	return cells

# This wonderful code was written by u/nwb712, tysm!
func _update_surrounding(pos: Vector2):
	var surrounding = tilemap.foreground.get_surrounding_cells(pos)
	var to_update = []
	for cell in surrounding:
		var cell_data = tilemap.foreground.get_cell_tile_data(cell)
		if tilemap.foreground.get_cell_source_id(cell) != -1 and cell_data and cell_data.get_custom_data("Breakable"):
			to_update.append(cell)
	for cell in to_update:
		tilemap.foreground.set_cell(cell, -1)
	tilemap.foreground.set_cells_terrain_connect(to_update, 0, 0)

# Calls level_base.gd so arrays can properly be updated, then detonates locally
func die():
	get_tree().current_scene.detonate_bomb(self)

func remove():
	queue_free()
