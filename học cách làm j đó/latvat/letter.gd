extends Area2D

@export var letter := "a"
@export var speed := 100.0
@export var target_letter_label: Label = null 
@export var diem_label: Label = null
func _ready():
	$Label.text = letter

	set_meta("letter", letter) 

	if target_letter_label == null:
		print("Chưa gán target_letter_label!")

	if diem_label == null:
		diem_label = get_node_or_null("$diem")
		if diem_label == null:
			print("Không tìm thấy node 'diem'!")
func _process(delta):
	position.y += speed * delta
	if position.y > 500: # hoặc chiều cao màn hình
		queue_free()



func _on_body_entered(body):
	if body.has_method("main"):
		if int(diem_label.text) < 6:
			if target_letter_label != null:
				if letter == target_letter_label.text:
					print("Đúng rồi!")
					if diem_label != null:
						diem_label.text = str(int(diem_label.text) + 1)
					else:
						print("Lỗi: diem_label chưa được gán!")
				else:
					print("Sai rồi!")
					print("Mục tiêu:", target_letter_label.text)
					print("Chữ:", letter)
	
		print("hehe")
		queue_free()
func lt():
	pass
	
