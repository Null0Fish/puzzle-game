extends Node2D

const TILE_SIZE = Global.TILE_SIZE

@onready var tilemap : TileMapLayer = $GlobalTileMap
@onready var player : CharacterBody2D = $Player
@onready var guis : Array = $LevelGUI.get_guis()
@onready var level_label : Label = $LevelLabel

var bomb_scene : PackedScene = preload("res://scenes/bomb.tscn")

var bombs_placed : Array = []
var bomb_locations : Array = []
var crates : Array = []
var labels : Array = []
var bombs_available : Array

func _ready():
	level_label.text = "Level: " + str(Global.get_current_level() + 1)
	Global.paused = false
	Global.current_bomb_type = Global.DIAGONAL
	var level_num = Global.get_current_level()
	bombs_available = Global.get_bombs_available(level_num)
	for bomb_type in bombs_available.size():
		guis[bomb_type].set_bomb_count(bombs_available[bomb_type])
		guis[bomb_type].set_type(bomb_type)
	for child in get_children():
		if child is Crate:
			crates.append(child)

func _process(_delta):
	for bomb in bombs_placed:
		var index = bombs_placed.find(bomb)
		bomb_locations[index] = tilemap.local_to_map(bomb.position)

func upgrade_bomb_type(type : int):
	guis[type].upgrade()

func handle_left_click(cell : Vector2i):
	if can_place_bomb(cell, Global.current_bomb_type):
		place_bomb(cell, Global.current_bomb_type)
	elif bomb_locations.has(cell):
		var i = bomb_locations.find(cell)
		var bomb = bombs_placed[i]
		bomb_locations.remove_at(i)
		bombs_placed.remove_at(i)
		bombs_available[bomb.type] += 1
		tilemap.static_objects.remove_at(tilemap.static_objects.find(bomb))
		bomb.remove()
		guis[bomb.type].set_bomb_count(bombs_available[bomb.type])
		

func handle_right_click(cell : Vector2i):
	var bomb = bombs_placed[bomb_locations.find(cell)]
	if bomb.is_on_floor() or true:
		detonate_bomb(bomb)

func place_bomb(cell : Vector2i, type : int):
	var bomb = bomb_scene.instantiate()
	bomb.set_position(Vector2(
		cell.x * TILE_SIZE + TILE_SIZE / 2, 
		cell.y * TILE_SIZE + TILE_SIZE / 2
	))
	add_child(bomb)
	bomb.init(tilemap, type)
	bombs_placed.append(bomb)
	bomb_locations.append(cell)
	bombs_available[type] -= 1
	guis[type].set_bomb_count(bombs_available[type])

func detonate_bomb(bomb : Bomb):
	var index = bombs_placed.find(bomb)
	bombs_placed[index].detonate(tilemap.local_to_map(player.global_position))
	bombs_placed.remove_at(index)
	bomb_locations.remove_at(index)

func get_all_crate_cells() -> Array:
	var cells = []
	for crate in crates:
		cells.append(tilemap.get_near_cells(crate))
	return cells

func can_place_bomb(cell: Vector2i, type: int) -> bool:
	if bombs_available[type] <= 0:
		return false
	if bomb_locations.has(cell):
		return false
	if not player.is_on_floor() or tilemap.get_player_cells().has(cell):
		return false
	for crate in get_all_crate_cells():
		if crate.has(cell):
			return false
	return true

func _on_area_2d_body_entered(body):
	if body is Player:
		body.call_deferred("die")
