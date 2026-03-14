extends Node2D

@onready var bgms = $AudioStreamPlayer2D
@onready var hd = $AudioStreamPlayer
@onready var player = $player/player
@onready var platform = $StaticBody2D
@onready var safe_zone = $Area2D3
@onready var boxes = [$Sprite2D, $Sprite2D2, $Sprite2D3]
@onready var answer_box = $Sprite2D4
@onready var clock = $diem
@onready var sound_red = $do
@onready var sound_blue = $xanhduon
@onready var sound_white = $trang
@onready var sound_correct = $khen
@onready var sound_wrong = $sai
@onready var label_tong_diem = $tongdiem
@onready var label_ky_luc = $"kỷ lục"
@onready var label_tung_vong = $tungvong
@onready var thong_bao_dung = $Dungr
@onready var nen_dung = $nenxanh
@onready var thong_bao_sai = $Sai
@onready var nen_sai = $nendo

var score := 0
var high_score := 0
var scores_per_round := []
var round_count := 0
var max_rounds := 5
var last_correct_color: Color = Color(0, 0, 0)
var can_countdown := false
var timer := 15.0
var platform_gone := false
var safe_positions = [300, 550, 800]
var safe_x := 0
var box_positions = [Vector2(296.5, 465.5), Vector2(540, 469), Vector2(781.5, 467.5)]
var colors = [Color.RED, Color.BLUE, Color.WHITE]
var correct_color: Color
var game_running := true

func _ready():
	$Button.visible = false
	label_tong_diem.visible = false
	label_ky_luc.visible = false
	label_tung_vong.visible = false
	thong_bao_dung.visible = false
	nen_dung.visible = false
	nen_sai.visible = false
	thong_bao_sai.visible = false
	$nencuoi.visible = false
	up_date_music_start()
	randomize()
	await start_game()

func _process(delta):
	if Input.is_action_just_pressed("ui_thoat"):
		thoat()
	print($player/player.position)
	if not game_running or not can_countdown:
		return

	timer = max(timer - delta, 0)
	clock.text = str(round(timer))

	if timer <= 0 or Input.is_action_just_pressed("ui_accept"):
		end_round()
		await get_tree().create_timer(1).timeout
		start_new_round()
func thoat():
	print("Thoat scene")
	get_tree().change_scene_to_file("res://menu.tscn")
func up_date_music_start():
	if not bgms.playing:
		bgms.play()
		print("🎵 Nhạc nền phát...")

func start_game():
	hd.play()
	await hd.finished
	print("🔊 Hướng dẫn đã phát xong.")
	start_new_round()

func start_new_round():
	if round_count >= max_rounds:
		show_end_summary()
		return

	round_count += 1
	timer = 15.0
	game_running = true
	can_countdown = false
	platform_gone = false

	if platform == null:
		var new_platform = preload("res://lv/static_body_2d.tscn").instantiate()
		add_child(new_platform)
		new_platform.position = Vector2(504, 352)
		platform = new_platform

	player.position = Vector2(50, 296)
	player.velocity = Vector2.ZERO
	player.set_physics_process(true)
	player.current_pos_index = 0

	box_positions.shuffle()
	for i in range(3):
		boxes[i].position = box_positions[i]

	colors.shuffle()
	for i in range(3):
		boxes[i].modulate = colors[i]

	while true:
		correct_color = colors[randi() % 3]
		answer_box.modulate = correct_color
		if correct_color != last_correct_color:
			break
	last_correct_color = correct_color

	for i in range(3):
		if boxes[i].modulate == correct_color:
			safe_x = boxes[i].position.x
			break
	safe_zone.position.x = safe_x

	match correct_color:
		Color.RED: sound_red.play()
		Color.BLUE: sound_blue.play()
		Color.WHITE: sound_white.play()

	print("🟨 Màu đúng là:", correct_color, "| Safe zone tại:", safe_x)
	await get_tree().create_timer(1.5).timeout
	can_countdown = true

func end_round():
	game_running = false
	can_countdown = false

	var player_x = player.position.x
	var round_score := 0
	var success := false
	var tolerance := 20.0  # khoảng sai số chấp nhận được (pixels)

	for box in boxes:
		if box.modulate == correct_color and abs(player_x - box.position.x) <= tolerance:
			success = true
			break

	if success:
		print("✅ Bạn an toàn!")
		thong_bao_dung.visible = true
		nen_dung.visible = true
		
		sound_correct.play()
		round_score = 10
		await get_tree().create_timer(1).timeout
		thong_bao_dung.visible = false
		nen_dung.visible = false
	else:
		print("❌ Sai rồi, rơi xuống!")
		if platform:
			platform.queue_free()
			platform = null
		thong_bao_sai.visible = true
		nen_sai.visible = true
		sound_wrong.play()
		await get_tree().create_timer(1).timeout
		thong_bao_sai.visible = false
		nen_sai.visible = false

	score += round_score
	scores_per_round.append(round_score)
	if score > high_score:
		high_score = score
		print("🏆 Kỷ lục mới:", high_score)

	print("🔢 Điểm vòng này:", round_score, "| Tổng điểm:", score)
	platform_gone = true

func get_closest_box(player_x: float) -> Sprite2D:
	var closest = boxes[0]
	var min_dist = abs(boxes[0].position.x - player_x)
	for box in boxes:
		var dist = abs(box.position.x - player_x)
		if dist < min_dist:
			min_dist = dist
			closest = box
	return closest

func show_end_summary():
	label_tong_diem.text = "📊 Tổng điểm: " + str(score)
	label_ky_luc.text = "🏆 Kỷ lục: " + str(high_score)
	var diem_text = "🎮 Điểm từng vòng:\n"
	for i in range(scores_per_round.size()):
		diem_text += "   Vòng " + str(i + 1) + ": " + str(scores_per_round[i]) + " điểm\n"
	label_tung_vong.text = diem_text

	label_tong_diem.visible = true
	label_ky_luc.visible = true
	label_tung_vong.visible = false
	$Button.visible = true
	$nencuoi.visible = true

	game_running = false
	can_countdown = false
	thong_bao_dung.visible = false
	thong_bao_sai.visible = false
	print("🏁 Trò chơi kết thúc.")
