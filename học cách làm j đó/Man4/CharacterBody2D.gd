extends CharacterBody2D

@export var move_speed := 200.0

var target_position: Vector2
var moving := false

func _physics_process(delta):
	if moving:
		var direction = target_position - global_position
		
		if abs(direction.x) > 5:
			velocity = Vector2(sign(direction.x) * move_speed, 0)
			move_and_slide()
		else:
			velocity = Vector2.ZERO
			moving = false

func move_to(pos: Vector2):
	target_position = pos
	moving = true
