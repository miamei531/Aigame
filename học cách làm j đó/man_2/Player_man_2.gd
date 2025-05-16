extends CharacterBody2D

var positions = [Vector2(536, 320), Vector2(536, 480)]
var positions_ngang=[Vector2(216,480),Vector2(536,480),Vector2(856,480)]
var current_index = 0
var check = 0
var is_facing_front = true
var turn = false
func _ready():
	position = positions[current_index]
	$AnimatedSprite2D.play("front")

func _process(_delta):
	if turn:
		$AnimatedSprite2D.play("front")   # quay lưng lại
		is_facing_front = true
		turn=false
	if Input.is_action_just_pressed("ui_up") and check == 0 :
		jump_to_next_position()
	if Input.is_action_just_pressed("ui_left") and position.y == 480:
		jump_to_left()
	if Input.is_action_just_pressed("ui_right") and position.y == 480:
		jump_to_right()
	if Input.is_action_just_pressed("ui_down") and position.y == 480:
		$AnimatedSprite2D.play("back")   # quay lưng lại
		is_facing_front = false


func jump_to_next_position():
	# Không kiểm tra tween đang chạy nữa (đơn giản hoá)
	if current_index < positions.size() - 1 and is_facing_front:
		current_index += 1
		var target_position = positions[current_index]
		var tween = create_tween()
		tween.tween_property(self, "position", target_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	if current_index > 0 and !is_facing_front:
		current_index -= 1
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
