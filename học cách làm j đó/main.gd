extends Node2D
@onready var bgms = $AudioStreamPlayer2D
@onready var hd = $AudioStreamPlayer
@onready var player = $player/player
@onready var platform = $StaticBody2D
@onready var safe_zone = $Area2D3
@onready var boxes = [$Sprite2D,$Sprite2D2 , $Sprite2D3]
@onready var answer_box = $Sprite2D4
@onready var clock = $diem
@onready var sound_red = $do
@onready var sound_blue = $xanhduon
@onready var sound_white = $trang
@onready var sound_correct = $khen # âm thanh khuyến khích
@onready var sound_wrong = $sai    # âm thanh cổ vũ
var last_correct_color: Color = Color(0, 0, 0)  # ban đầu là màu bất kỳ không có trong danh sách
var can_countdown := false  
var timer := 15.0
var platform_gone := false
var safe_positions = [300, 550, 800]
var safe_x := 0
var box_positions = [Vector2(304, 464), Vector2(544, 464), Vector2(784, 464)]  # các vị trí hoán đổi
var colors = [Color.RED, Color.BLUE, Color.WHITE]
var correct_color: Color
var game_running := true
func _ready():
	up_date_music_start()
	safe_x = safe_positions[randi() % safe_positions.size()]
	safe_zone.position.x = safe_x
	print("Safe zone at:", safe_x)
	randomize()
	start_game()

func _process(delta):
	if not game_running or not can_countdown:
		return

	timer -= delta
	$diem.text = str(round(timer))  # ✅ Cập nhật Label thời gian

	if timer <= 0 or Input.is_action_just_pressed("ui_accept") and game_running:
		end_round()
		await get_tree().create_timer(1).timeout
		start_new_round()
	if platform_gone:
		return

	#timer -= delta

	if timer <= 0:
		var player_x = player.position.x  # Không cần dùng global_position ở đây nếu cùng hệ tọa độ
		print("Player đang ở:", player_x, "| Safe zone tại:", safe_x)

		if abs(player_x - safe_x) <= 10:
			await get_tree().create_timer(1).timeout
			print("✅ Bạn an toàn!")
			$Dungr.visible = true
			print ($Dungr.visible )
			await get_tree().create_timer(1).timeout
			
			
		else:
			platform.queue_free()
			platform = null
			print("❌ Bạn đã rơi xuống!")

		platform_gone = true
func start_new_round():
	timer = 15.0
	game_running = true
	platform_gone = false
	# Reset lại đồng hồ
	#clock.reset_timer()
	# Reset lại nền nếu bị xóa
	if platform == null:
		var new_platform = preload("res://lv/static_body_2d.tscn").instantiate()
		add_child(new_platform)
		new_platform.position = Vector2(504, 352)
		platform = new_platform

	# ✅ Reset vị trí và trạng thái nhân vật
	player.position = Vector2(50, 296)
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	# Cập nhật chỉ số vị trí tương ứng
	player.current_pos_index = 0

	# Hoán đổi box
	box_positions.shuffle()
	for i in range(3):
		boxes[i].position = box_positions[i]

	# Gán màu
	colors.shuffle()
	for i in range(3):
		boxes[i].modulate = colors[i]

	
	# ✅ Chọn màu đúng và cập nhật safe zone khớp box đúng màu
	while true:
		correct_color = colors[randi() % 3]
		answer_box.modulate = correct_color
		if correct_color != last_correct_color:
			break  # nếu khác màu cũ thì chấp nhận
	# lưu lại màu này cho vòng sau
	last_correct_color = correct_color

	for i in range(3):
		if boxes[i].modulate == correct_color:
			safe_x = boxes[i].position.x
			break

	safe_zone.position.x = safe_x
	print("🟨 Màu đúng là:", correct_color, "| Safe zone tại:", safe_x)
	match correct_color:
		Color.RED:
			sound_red.play()
		Color.BLUE:
			sound_blue.play()
		Color.WHITE:
			sound_white.play()

	await get_tree().create_timer(1.5).timeout  # Chờ âm thanh phát xong trước khi bắt đầu chơi
	can_countdown = true  # Cho phép đếm ngược
func end_round():
	game_running = false
	
	var player_x = player.position.x
	var closest_box = get_closest_box(player_x)
	if closest_box.modulate == correct_color:
		print("✅ Bạn an toàn!")
		$Dungr.visible = true
		sound_correct.play()  # ✅ Âm thanh khuyến khích
		await get_tree().create_timer(1).timeout
		$Dungr.visible = false
	else:
		print("❌ Sai rồi, rơi xuống!")
		platform.queue_free()
		$Sai.visible = true
		sound_wrong.play()  # ✅ Âm thanh cổ vũ
		await get_tree().create_timer(1).timeout
		$Sai.visible = false
	
	platform_gone = true
	
func get_closest_box(player_x: float) -> Sprite2D:
	var closest: Sprite2D = boxes[0]
	var min_dist: float = abs(boxes[0].position.x - player_x)

	for box in boxes:
		var dist = abs(box.position.x - player_x)
		if dist < min_dist:
			min_dist = dist
			closest = box

	return closest
func up_date_music_start():
	if !bgms.playing :
		bgms.play()
		print("nhạc chạy")
func start_game():
	# Bắt đầu phát nhạc hướng dẫn
	hd.play()
	await hd.finished  # Đợi nhạc phát xong
	print("🔊 Nhạc đã phát xong. Bắt đầu trò chơi.")
	can_countdown = true  # ✅ Cho phép bắt đầu đếm ngược
	start_new_round()
