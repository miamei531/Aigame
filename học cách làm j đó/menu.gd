extends Node2D

@onready var bgms := $AudioStreamPlayer
@onready var buttons := [$Button, $Button2, $Button3,$Button5]
var selected_index := 0

var center := Vector2()

func _ready():
	center = Vector2(450, 210)
	await get_tree().create_timer(0.5).timeout
	update_button_slide()

func _process(_delta):
	up_date_music_start()

	if Input.is_action_just_pressed("ui_right"):
		selected_index = (selected_index + 1) % buttons.size()
		update_button_slide()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_button_slide()

	if Input.is_action_just_pressed("ui_accept"):
		await get_tree().create_timer(0.2)
		buttons[selected_index].emit_signal("pressed")

func update_button_slide():
	for i in range(buttons.size()):
		var btn = buttons[i]
		var tween = create_tween()

		if i == selected_index:
			btn.visible = true
			tween.tween_property(btn, "position", center, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(btn, "scale", Vector2(1.4, 1.4), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			tween.tween_property(btn, "modulate", Color(1, 1, 1, 1), 0.3)
		else:
			tween.tween_property(btn, "modulate", Color(1, 1, 1, 0), 0.3)
			await tween.finished
			btn.visible = false

func up_date_music_start():
	if !bgms.playing:
		bgms.play()



func _on_button_pressed():
	get_tree().change_scene_to_file("res://dohoa/node_2d.tscn")


func _on_button_2_pressed():
	get_tree().change_scene_to_file("res://man_2/man_2.tscn")



func _on_button_3_pressed():
	get_tree().change_scene_to_file("res://lv/man3.tscn")
