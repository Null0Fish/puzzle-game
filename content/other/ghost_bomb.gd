extends Sprite2D

const TILE_SIZE = int(Global.TILE_SIZE)
const OFFSET = Global.OFFSET

var tween: Tween = null

func _process(_delta: float) -> void:
	var target_position = Vector2i(get_global_mouse_position()) / TILE_SIZE * TILE_SIZE + OFFSET
	_move_ghost_bomb(target_position)

func _move_ghost_bomb(target_position: Vector2):
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.25).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
