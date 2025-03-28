extends GridContainer

func _ready():
	for i in get_children().size():
		var level_box = get_children()[i]
		var level_num = level_box.get_index()
		level_box.set_level(level_num + 1)
		level_box.set_locked(not Global.unlocked_levels.has(level_num))
