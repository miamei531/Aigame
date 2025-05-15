extends Node2D
@onready var bgms :=$AudioStreamPlayer
@onready var buttons := [$Button, $Button2, $Button3]
var selected_index := 0

func _ready():
	update_button_focus()

func _process(delta):
	up_date_music_start()
	
	# Điều hướng giữa các nút
	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_button_focus()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_button_focus()

	# Chọn bằng phím Space
	if Input.is_action_just_pressed("ui_accept"):
		buttons[selected_index].emit_signal("pressed")

func update_button_focus():
	for i in range(buttons.size()):
		if i == selected_index:
			buttons[i].grab_focus()
		else:
			buttons[i].release_focus()
func up_date_music_start():
	if !bgms.playing :
		bgms.play()
		print("nhạc chạy")


func _on_button_pressed():
	get_tree().change_scene_to_file("res://man_1.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://man_2/man_2.tscn")



func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://lv/man3.tscn")
