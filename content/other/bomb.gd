extends RigidBody2D

class_name Bomb

const ADJACENT: int = Global.ADJACENT
const DIAGONAL: int = Global.DIAGONAL
const FULL: int = Global.FULL
const WARNING_TILE_ATLAS: Vector2i = Vector2i(0, 0)
const WARNING_ID: int = 0
const TILE_SIZE: int = int(Global.TILE_SIZE)

@onready var bomb_sprite: Sprite2D = $BombSprite
@onready var warning_layers: Node2D = $WarningLayers
@onready var opaque_warning_layer: TileMapLayer = $WarningLayers/OpaqueWarningLayer
@onready var solid_warning_layer: TileMapLayer = $WarningLayers/SolidWarningLayer
@onready var raycast: RayCast2D = $RayCast2D
@onready var ghost_bomb: Sprite2D = $GhostBomb

var explosion_scene = preload("res://content/effects/explosion_particles.tscn")
var root_tile_layer: TileMapLayer
var type: int
var cells_to_detonate: Array = []
var dragging: bool = false
var inital_cell_pos = Vector2i(TILE_SIZE * 2, 0)
var delta_cell_pos = Vector2i(0, TILE_SIZE)
var player: Player

func _process(_delta):
	ghost_bomb.region_rect = bomb_sprite.region_rect
	_update_warning_cells()
	if dragging:
		bomb_sprite.modulate.a = .5
		ghost_bomb.show()
		warning_layers.hide()
	else:
		bomb_sprite.modulate.a = 1
		ghost_bomb.hide()
		warning_layers.show()

func _scene_root():
	return get_tree().get_current_scene()

func _on_panel_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				_scene_root().is_dragging = true
			else:
				if dragging:
					dragging = false
					_scene_root().is_dragging = false
					_scene_root().try_move_bomb_to(get_global_mouse_position(), self)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.call_deferred("die")

func _update_warning_cells():
	solid_warning_layer.global_position = Vector2.ZERO
	opaque_warning_layer.global_position = Vector2.ZERO
	solid_warning_layer.clear()
	opaque_warning_layer.clear()
	cells_to_detonate = _get_cells_to_detonate(root_tile_layer.local_to_map(global_position))
	for cell in cells_to_detonate:
		if not Global.has_solid_warning_tile_at(cell):
			solid_warning_layer.set_cell(cell, WARNING_ID, WARNING_TILE_ATLAS)
		else:
			opaque_warning_layer.set_cell(cell, WARNING_ID, WARNING_TILE_ATLAS)

func _create_explosion_particles(cell: Vector2i):
	var particles = explosion_scene.instantiate()
	particles.global_position = root_tile_layer.map_to_local(cell)
	particles.get_child(0).emitting = true
	get_tree().current_scene.add_child(particles)

func _get_cells_to_detonate(cell: Vector2i) -> Array:
	var bomb_level = Global.bomb_levels[type]
	var cells = []
	cells.append(cell)
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

func _update_surrounding(pos: Vector2):
	var surrounding = root_tile_layer.foreground_layer.get_surrounding_cells(pos)
	var to_update = []
	for cell in surrounding:
		var cell_data = root_tile_layer.foreground_layer.get_cell_tile_data(cell)
		if root_tile_layer.foreground_layer.get_cell_source_id(cell) != -1 and cell_data and cell_data.get_custom_data("Breakable"):
			to_update.append(cell)
	for cell in to_update:
		root_tile_layer.foreground_layer.set_cell(cell, -1)
	root_tile_layer.foreground_layer.set_cells_terrain_connect(to_update, 0, 0)

func _is_wall_cell(cell: Vector2i) -> bool:
	if cell.x < 0 or cell.x > 19:
		return true
	if cell.y < 0 or cell.y > 11:
		return true
	return false

func init(map: TileMapLayer, variant: int):
	root_tile_layer = map
	type = variant
	var region_rect = Rect2i(inital_cell_pos + delta_cell_pos * type, Vector2i(TILE_SIZE, TILE_SIZE))
	bomb_sprite.region_rect = region_rect
	Global.solid_warning_layers.append(solid_warning_layer)
	root_tile_layer.static_objects.append(self)
	
	if dragging:
		ghost_bomb.show()
	else:
		ghost_bomb.hide()

func is_on_floor() -> bool:
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider is TileMapLayer or collider is RigidBody2D or collider is Crate:
			return true
	return false

func detonate(player_cell: Vector2i):	
	root_tile_layer.static_objects.erase(self)
	for cell in cells_to_detonate:
		if cell == player_cell:
			player.die()
			return
		var cell_data = root_tile_layer.foreground_layer.get_cell_tile_data(cell)
		if cell_data and cell_data.get_custom_data("Breakable") \
		and not cell in Global.GUI_CELLS and not _is_wall_cell(cell):
			_create_explosion_particles(cell)
			root_tile_layer.foreground_layer.set_cell(cell, -1)
			_update_surrounding(cell)
		root_tile_layer.ore_layer.set_cell(cell, -1)

func die():
	get_tree().current_scene.try_detonate_bomb(root_tile_layer.local_to_map(position), true)

func remove():
	# VERY BAD CODE
	var index = Global.solid_warning_layers.find(solid_warning_layer)
	if index != -1:
		Global.solid_warning_layers.remove_at(index)
	queue_free()

# Pretty lame code so the region does not need to be recalculated localy kinda bad
func upgrade_bomb_sprite(rect: Rect2i):
	bomb_sprite.region_rect = rect
