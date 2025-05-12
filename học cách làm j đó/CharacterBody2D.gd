extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var facing_direction = 1  # 1 = phải, -1 = trái, 
@onready var target_letter_label = get_node("/root/Main/TargetLetterLabel")

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

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
	pass
func main():
	pass
