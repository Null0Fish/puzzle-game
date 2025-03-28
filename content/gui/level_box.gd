extends PanelContainer

var locked
var level_num

@onready var lock = $Lock
@onready var label = $Node2D/Label

func set_locked(status : bool):
	locked = status
	lock.visible = status
	label.visible = not status

func set_level(num : int):
	level_num = num
	label.text = str(num)

func _on_gui_input(event):
	if not locked and event is InputEventMouseButton and event.is_released():
		Global.set_level(level_num - 1)
