extends Node2D

@onready var sound_correct = $khen # âm thanh khuyến khích
@onready var sound_wrong = $sai   
@onready var bgms = $nen
@onready var hd = $hd
@onready var diem_label = $diemso
@onready var diem_so = $diem
@onready var ket_thuc_label = $ketthuc # Label để hiện kết quả
@onready var Dungr = $Dungr

var thoi_gian_choi = 0.0
const THOI_GIAN_GIOI_HAN = 180.0  # 3 phút = 180 giây
var choi_xong = false

func _ready():
	$Button.visible = false
	$Sprite2D.visible = false
	var mini_scene = preload("res://latvat/letter.tscn").instantiate()
	mini_scene.diem_label = diem_label  # truyền Label từ scene chính vào
	add_child(mini_scene)
	ket_thuc_label.visible = false
	Dungr.visible = false

func _process(delta):
	if choi_xong:
		return
	
	thoi_gian_choi += delta
	up_date_music_start()

	#if diem_so.text == "6":
		#Dungr.visible = true

	if thoi_gian_choi >= THOI_GIAN_GIOI_HAN or diem_so.text == "6":
		ket_thuc_man_choi()
	#if Input.is_action_just_pressed("ui_down"):
		

func up_date_music_start():
	if !bgms.playing:
		bgms.play()
		hd.play()
		print("nhạc chạy")

func ket_thuc_man_choi():
	choi_xong = true
	
	bgms.stop()
	hd.stop()
	$Button.visible = true
	var tong_diem = diem_so.text
	var thoi_gian_da_choi = int(thoi_gian_choi)
	var phut = thoi_gian_da_choi / 60
	var giay = thoi_gian_da_choi % 60
	var time_str = "%00d:%02d" % [phut, giay]

	ket_thuc_label.text = "Tổng kết\nSố chữ: %s\nThời gian: %s" % [tong_diem, time_str]
	ket_thuc_label.visible = true
	$Sprite2D.visible = true
	print("Kết thúc màn chơi")


func _on_button_pressed():
	get_tree().change_scene_to_file("res://menu.tscn")
