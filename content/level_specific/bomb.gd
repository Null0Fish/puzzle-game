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

var tile_layers: TileMapLayer
var type: int
var cells_to_detonate: Array = []

func init(map: TileMapLayer, variant: int):
	tile_layers = map
	type = variant
	bomb_sprite.texture = BOMB_TEXTURES[type]
	tile_layers.static_objects.append(self)

func _process(_delta):
	_detect_player_collision()
	_update_warning_cells()

func _detect_player_collision():
	if raycast.is_colliding() and raycast.get_collider() is Player:
		Global.reset()

func _update_warning_cells():
	cells_to_detonate = _get_cells_to_detonate(tile_layers.local_to_map(global_position))
	for cell in cells_to_detonate:
		if tile_layers.warning.get_cell_source_id(cell) != -1:
			var atlas_pos = tile_layers.warning.get_cell_atlas_coords(cell)
			if atlas_pos != Vector2i(0, 2):
				tile_layers.warning.set_cell(cell, WARNING_ID, atlas_pos + Vector2i(1, 0))
			else:
				print("Not enough bomb warning tiles in atlas!")
		else:
			tile_layers.warning.set_cell(cell, WARNING_ID, WARNING_TILE_ATLAS)

func is_on_floor() -> bool:
	return raycast.is_colliding() and (raycast.get_collider() is TileMap or raycast.get_collider() is RigidBody2D)

func detonate(player_cell: Vector2i):
	var explosion_scene = preload("res://content/level_specific/explosion_particles.tscn")
	
	tile_layers.static_objects.erase(self)
	
	for cell in cells_to_detonate:

		if cell == player_cell:
			Global.reset()
		tile_layers.warning.set_cell(cell, -1)
		var cell_data = tile_layers.foreground.get_cell_tile_data(cell)
		if cell_data and cell_data.get_custom_data("Breakable"):
			var particles = explosion_scene.instantiate()
			particles.global_position = tile_layers.map_to_local(cell)
			particles.get_child(0).emitting = true
			get_tree().current_scene.add_child(particles)
			tile_layers.foreground.set_cell(cell, -1)
			_update_surrounding(cell)
		tile_layers.ores.set_cell(cell, -1)
	
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
	var surrounding = tile_layers.foreground.get_surrounding_cells(pos)
	var to_update = []
	for cell in surrounding:
		var cell_data = tile_layers.foreground.get_cell_tile_data(cell)
		if tile_layers.foreground.get_cell_source_id(cell) != -1 and cell_data and cell_data.get_custom_data("Breakable"):
			to_update.append(cell)
	for cell in to_update:
		tile_layers.foreground.set_cell(cell, -1)
	tile_layers.foreground.set_cells_terrain_connect(to_update, 0, 0)

# Calls level_base.gd so arrays can properly be updated, then detonates locally
func die():
	get_tree().current_scene.detonate_bomb(self)

func remove():
	queue_free()
