extends Area2D


@export var letter := "a"
@export var speed := 100.0

func _ready():
	$Label.text = letter

func _process(delta):
	position.y += speed * delta
	if position.y > 400: # hoặc chiều cao màn hình
		queue_free()
