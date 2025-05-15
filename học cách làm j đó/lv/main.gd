extends Node2D
@onready var sound_correct = $khen # âm thanh khuyến khích
@onready var sound_wrong = $sai   
@onready var bgms = $nen
func _ready():
	var mini_scene = preload("res://latvat/letter.tscn").instantiate()
	mini_scene.diem_label = $DiemLabel  # truyền Label từ scene chính vào
	add_child(mini_scene)
	
func _process(delta):
	up_date_music_start()
	if $diem.text == '6':
		$Dungr.visible = true
func up_date_music_start():
	if !bgms.playing :
		bgms.play()
		print("nhạc chạy")
