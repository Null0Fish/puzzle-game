extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var pickup_player: AudioStreamPlayer = $PickupPlayer

const SIZE = Vector2i(16, 16)
const OFFSET = Vector2i(0, 1)
const SOURCE_ID: int = 1

var lock_block_atlas_cords : Vector2i
var foreground_layer: TileMapLayer

func init(atlas_cords: Vector2i, tile_layer: TileMapLayer) -> void:
	foreground_layer = tile_layer
	var new_rect = Rect2i(Vector2i(atlas_cords.x * 16, atlas_cords.y * 16), SIZE)
	sprite_2d.region_rect = new_rect
	lock_block_atlas_cords = atlas_cords + OFFSET

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		_unlock_cells()
		pickup_player.play()
		hide()
		await pickup_player.finished
		queue_free()

func _unlock_cells():
	for cell in foreground_layer.get_used_cells():
		if foreground_layer.get_cell_atlas_coords(cell) == lock_block_atlas_cords:
			var id = foreground_layer.get_cell_source_id(cell)
			if id == SOURCE_ID:
				foreground_layer.set_cell(cell, -1)
