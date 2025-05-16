extends Node2D

# Danh sách màu và âm thanh
var colors = [Color.RED, Color.BLUE, Color.WHITE,Color.ALICE_BLUE]
var color_names = ["MÀU ĐỎ", "MÀU XANH DƯƠNG", "MÀU TRẮNG","BÉ ĐÃ SẴN SÀNG CHƯA ?"]
var sounds = []

var current_index = 0

@onready var color_rect = $ColorRect
@onready var label = $Label
@onready var audio_red = $"mau do"
@onready var audio_blue =$"mau xanh"
@onready var audio_white = $"màu trắng"
@onready var audio_ss = $sansang

func _ready():
	
	# Danh sách các AudioPlayer tương ứng thứ tự màu
	sounds = [audio_red, audio_blue, audio_white,audio_ss]
	update_screen()

func _process(delta):
	if Input.is_action_just_pressed("ui_down"):
		current_index = (current_index + 1) % colors.size()
		update_screen()

	if Input.is_action_just_pressed("ui_accept"): # Mặc định là phím Space
		sounds[current_index].play()
	if Input.is_action_just_pressed("ui_accept") and sounds[current_index] == audio_ss : 
		sounds[current_index].play()
		await get_tree().create_timer(1.49).timeout
		get_tree().change_scene_to_file("res://man_1.tscn")

func update_screen():
	color_rect.color = colors[current_index]
	label.text = color_names[current_index]
