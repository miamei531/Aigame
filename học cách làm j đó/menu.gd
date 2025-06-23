extends Node2D

@onready var bgms := $AudioStreamPlayer
@onready var buttons := [$Button, $Button2, $Button3, $Button5]
var selected_index := 0

# Tâm màn hình (chỉnh nếu khác)
var screen_center := Vector2(476, 120)

# Offset vị trí lệch từ trung tâm
var position_offsets := [
	Vector2(-400, 100),  # Trái xa
	Vector2(-200, 100),  # Trái gần
	Vector2(0, 0),     # Trung tâm
	Vector2(400, 100),   # Phải gần
	Vector2(400, 100)    # Phải xa
]
# Scale tương ứng
var scale_list := [
	Vector2(0.6, 0.6),  # Trái xa
	Vector2(0.8, 0.8),  # Trái gần
	Vector2(1.8, 1.8),  # Trung tâm
	Vector2(0.8, 0.8),  # Phải gần
	Vector2(0.6, 0.6)   # Phải xa
]

func _ready():
	await get_tree().create_timer(0.3).timeout
	update_carousel()

func _process(_delta):
	up_date_music_start()

	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_carousel()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_carousel()

	if Input.is_action_just_pressed("ui_accept"):
		await get_tree().create_timer(0.3).timeout
		buttons[selected_index].emit_signal("pressed")

func update_carousel():
	for i in range(buttons.size()):
		var btn = buttons[i]
		var tween = create_tween()

		# Relative index: vị trí so với nút được chọn (âm trái, dương phải)
		var rel_idx = i - selected_index

		# Cho phép quay vòng: nếu rel_idx < -2 hoặc > 2 thì điều chỉnh
		if rel_idx < -2:
			rel_idx += buttons.size()
		elif rel_idx > 2:
			rel_idx -= buttons.size()

		var pos_index = rel_idx + 2  # để thành 0 → 4
		pos_index = clamp(pos_index, 0, 4)

		var target_pos = screen_center + position_offsets[pos_index]
		var target_scale = scale_list[pos_index]

		tween.tween_property(btn, "position", target_pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", target_scale, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func up_date_music_start():
	if !bgms.playing:
		bgms.play()



func _on_button_pressed():
	get_tree().change_scene_to_file("res://dohoa/node_2d.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://man_2/man_2.tscn")



func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://lv/man3.tscn")
