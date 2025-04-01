extends CenterContainer

@onready var timer: Timer = $Timer
@onready var title_lable: Label = $VBoxContainer/TitleLable
@onready var level_label: Label = $VBoxContainer/LevelLabel

const LEVEL_TEXT: String = "Level: "

var should_fade: bool

func _ready() -> void:
	show()
	should_fade = false
	timer.start(.5)

func _process(_delta: float) -> void:
	if should_fade:
		modulate.a -= .01

func _on_timer_timeout() -> void:
	should_fade = true

func set_title(text : String):
	title_lable.text = text

func set_level(text : String):
	level_label.text = LEVEL_TEXT + text
