extends Node2D

@onready var timer_label = $Label
var timer := 15.0

func _ready():
	timer_label.text = str(int(timer))

func _process(delta):
	if timer > 0:
		timer -= delta
		timer_label.text = str(int(timer))

func reset_timer():
	timer = 15.0
	timer_label.text = str(int(timer))
