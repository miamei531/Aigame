extends CharacterBody2D

@export var move_speed := 200.0
@export var jump_force := -400.0
@export var gravity := 800.0

@onready var anim = $AnimatedSprite2D

var target_position: Vector2
var moving := false
var jumping := false

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if jumping:
			jumping = false
	
	if moving:
		var direction = target_position - global_position
		
		if abs(direction.x) > 5:
			velocity.x = sign(direction.x) * move_speed
			anim.flip_h = velocity.x < 0
		else:
			velocity.x = 0
			moving = false
	else:
		velocity.x = 0
	
	move_and_slide()
	_update_animation()

func _update_animation():
	if jumping or not is_on_floor():
		anim.play("jump")
	elif moving:
		anim.play("walk")
	else:
		anim.play("idle")

func move_to(pos: Vector2):
	target_position = pos
	moving = true

func play_jump():
	if is_on_floor():
		jumping = true
		velocity.y = jump_force
