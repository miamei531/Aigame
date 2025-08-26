extends Node2D

@onready var buttons: Array[Button] = [$Button, $Button2, $Button3, $Button5, $Button4]
@onready var bgms: AudioStreamPlayer = $AudioStreamPlayer

# Các vị trí hiển thị
var positions: Array[Vector2] = [
	Vector2(462 - 2.3 * 180, 220 + 1.65 * 20),  # 0: ngoài trái
	Vector2(462 - 1.2 * 180, 220 + 1 * 20),     # 1: trái
	Vector2(462, 220),                          # 2: giữa (nút được chọn)
	Vector2(462 + 1.3925 * 180, 220 + 1 * 20),  # 3: phải
	Vector2(462 + 2.7 * 180, 220 + 1.65 * 20)   # 4: ngoài phải
]

var selected_index: int = 2  # LUÔN luôn là 2

func _ready():
	for btn in buttons:
		btn.set_size(Vector2(180, 180))  # Hoặc kích thước bạn mong muốn
	update_buttons()
	up_date_music_start()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		rotate_right(buttons)
		update_buttons()

	elif Input.is_action_just_pressed("ui_right"):
		rotate_left(buttons)
		update_buttons()

	elif Input.is_action_just_pressed("ui_accept"):
		buttons[selected_index].emit_signal("pressed")  # luôn là nút giữa
	elif Input.is_action_just_pressed("ui_down"):
		buttons[selected_index].emit_signal("pressed")
func update_buttons():
	var center_pos: int = 2
	var scale_step: float = 0.2
	var alpha_step: float = 0.4

	# Ẩn tất cả trước
	for btn: Button in buttons:
		btn.visible = false

	# Duyệt qua vị trí hiển thị
	for i: int in range(positions.size()):
		var btn_index: int = i - center_pos + selected_index
		if btn_index < 0 or btn_index >= buttons.size():
			continue

		var btn: Button = buttons[btn_index]
		var pos: Vector2 = positions[i]
		var offset: int = abs(i - center_pos)

		btn.visible = true
		btn.z_index = -offset

		var scale: Vector2 = Vector2(1.2 - offset * scale_step, 1.25 - offset * scale_step)
		var alpha: float = clamp(1.0 - offset * alpha_step, 0.0, 1.0)

		var tween: Tween = create_tween()
		tween.tween_property(btn, "position", pos, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "scale", scale, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tween.tween_property(btn, "modulate", Color(1, 1, 1, alpha), 0.3)

# Xoay mảng sang trái
func rotate_left(arr: Array) -> void:
	var first = arr.pop_front()
	arr.append(first)

# Xoay mảng sang phải
func rotate_right(arr: Array) -> void:
	var last = arr.pop_back()
	arr.insert(0, last)

# Chuyển cảnh theo nút
func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://dohoa/node_2d.tscn")

func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://man_2/man_2.tscn")

func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://lv/man3.tscn")
func up_date_music_start():
	if not bgms.playing:
		bgms.play()
		print("🎵 Nhạc nền phát...")


func _on_button_5_pressed():
	get_tree().change_scene_to_file("res://oanquan/gamemode.tscn")
