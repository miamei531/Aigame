extends Area2D

@export var letter := "m"
@export var speed := 100.0
@export var target_letter_label: Label = null 
@export var diem_label: Label = null
#func _ready():
	#$Label.text = letter
#
	#set_meta("letter", letter) 
#
	#if target_letter_label == null:
		#print("Chưa gán target_letter_label!")
#
	#if diem_label == null:
		#diem_label = get_node_or_null("$diem")
		#if diem_label == null:
			#print("Không tìm thấy node 'diem'!")
func _ready():
	$Label.text = letter
	set_meta("letter", letter)

	# Gán kích thước font ngẫu nhiên từ 60 đến 70
	var random_size = randi_range(50, 80)
	var font = $Label.get_theme_font("font") # lấy font hiện tại từ theme
	var font_override = font.duplicate() # tạo bản sao để không ảnh hưởng toàn hệ thống
	$Label.add_theme_font_override("font", font)
	$Label.add_theme_font_size_override("font_size", random_size)

	# Kiểm tra các node liên quan
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
			if target_letter_label != null:
				if letter == target_letter_label.text:
					print("Đúng rồi!")

					if diem_label.text < '6':
						if diem_label != null:
							diem_label.text = str(int(diem_label.text) + 1)
						else:
							print("Lỗi: diem_label chưa được gán!")
						$dung.play()
						await get_tree().create_timer(1).timeout
				elif diem_label.text !='0':
					print("Sai rồi!")
					diem_label.text = str(int(diem_label.text) - 1)
					print("Mục tiêu:", target_letter_label.text)
					print("Chữ:", letter)
					$sai.play()
					await get_tree().create_timer(1).timeout
	
	print("hehe")
	queue_free()
func lt():
	pass
	
