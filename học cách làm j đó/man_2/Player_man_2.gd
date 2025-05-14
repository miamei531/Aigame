extends CharacterBody2D

var positions = [Vector2(536, 320), Vector2(536, 480)]
var positions_ngang=[Vector2(400,480),Vector2(536,480),Vector2(600,480)]
var current_index = 0
var check = 0

func _ready():
	position = positions[current_index]

func _process(_delta):
	if Input.is_action_just_pressed("ui_up") and check == 0 :
		jump_to_next_position()
	if Input.is_action_just_pressed("ui_left") and position.y == 480:
		jump_to_left()
	if Input.is_action_just_pressed("ui_right") and position.y == 480:
		jump_to_right()
func jump_to_next_position():
	# Không kiểm tra tween đang chạy nữa (đơn giản hoá)
	if current_index < positions.size() - 1:
		current_index += 1
		var target_position = positions[current_index]
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
func jump_to_left():
	if check!= -1 :
		check-=1
		var index=1+check
		var target_position = positions_ngang[index]
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
func jump_to_right():
	if check!= 1 :
		check+=1
		var index=1+check
		var target_position = positions_ngang[index]
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
