
extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@onready var death_sensor = $DeathSensor

var positions = [50, 300, 550, 800]
var current_pos_index = 0

var jump_force = -500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_direction = 1  # 1 = phải, -1 = trái
func _ready():
	$AnimatedSprite2D.play("cucai")
func _process(delta):
	handle_input()
	
	# Áp dụng trọng lực
	if not is_on_floor():
		velocity.y += gravity * delta

	move_and_slide()

	# Debug
	#print("Velocity:", velocity, " | is_on_floor:", is_on_floor(), " | Pos Index:", current_pos_index, " | Position:", position)

func handle_input():
	# Thay đổi hướng mặt
	if Input.is_action_just_pressed("ui_left"):
		sprite.flip_h = true
		facing_direction = -1
	elif Input.is_action_just_pressed("ui_right"):
		sprite.flip_h = false
		facing_direction = 1

	# Nhảy + Dịch chuyển vị trí nếu đang đứng trên mặt đất
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = jump_force

		var new_index = current_pos_index + facing_direction
		if new_index >= 0 and new_index < positions.size():
			current_pos_index = new_index
			position.x = positions[current_pos_index]
func Main():
	pass
