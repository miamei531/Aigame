extends CharacterBody2D

const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var platform_positions = [200, 400, 600, 800]
var current_index = 0

func _ready():
	# Đặt nhân vật vào vị trí đầu tiên
	global_position.x = platform_positions[current_index]

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Di chuyển trái
	if Input.is_action_just_pressed("ui_left"):
		if current_index > 0:
			current_index -= 1
			global_position.x = platform_positions[current_index]

	# Di chuyển phải
	if Input.is_action_just_pressed("ui_right"):
		if current_index < platform_positions.size() - 1:
			current_index += 1
			global_position.x = platform_positions[current_index]

	move_and_slide()
#func _on_body_entered(body):
	#if body is Area2D and body.has_variable("letter"):
		#if body.letter == target_letter_label.text:
			#print("Đúng rồi!")
			#body.queue_free()
		#else:
			#print("Sai rồi!")

func _on_area_2d_body_entered(body):
	print("vào vùng")
	if body.has_method("lt"):
		var letter_cham_vao = body.get("letter")
		print("Chạm vào chữ: ", letter_cham_vao)

		var target_letter = $"../Targetletter".letter  # hoặc get_node("../Targetletter").letter

		if letter_cham_vao == target_letter:
			print("Đúng rồi!")
			body.queue_free()
		else:
			print("Sai rồi!")
			$sai.play()
	pass
func main():
	pass
