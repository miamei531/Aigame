extends Area2D

@export var letter := "a"
@export var speed := 100.0
@onready var target_letter_label: Label = null
func _ready():
	$Label.text = letter
	set_meta("letter", letter) 

func _process(delta):
	position.y += speed * delta
	if position.y > 500: # hoặc chiều cao màn hình
		queue_free()


func _on_body_entered(body):
		#if target_letter_label and letter == target_letter_label.text:
			#print("Đúng rồi!")
			## Tăng điểm tại đây nếu cần
		#else:
			#print("Sai rồi!")
			#queue_free()
		print("hehe")
		queue_free()
func lt():
	pass
	
