extends Label

@onready var timer: Timer = $Timer

var should_fade : bool = false

func _process(_delta: float) -> void:
	if should_fade:
		modulate.a -= .01

func _ready() -> void:
	timer.start(.5)



func _on_timer_timeout() -> void:
	should_fade = true
