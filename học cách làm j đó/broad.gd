extends Node2D

var cells = [] # Mảng chứa số quân trong từng ô
var current_player = 1 # 1 hoặc 2

func _ready():
	# Khởi tạo 5 dân cho mỗi ô dân và 10 quân cho mỗi quan
	cells = [10, 5, 5, 5, 5, 5, 5, 5, 5, 5, 10,] # tổng 12 ô
	update_board()

func update_board():
	for i in range(12):
		$"Area2D{i}/Label".text = str(cells[i])

func on_cell_pressed(cell_index):
	if not is_valid_move(cell_index):
		return
	var num = cells[cell_index]
	cells[cell_index] = 0
	var idx = cell_index
	while num > 0:
		idx = (idx + 1) % 12
		cells[idx] += 1
		num -= 1
	# Kiểm tra ăn quân (luật cụ thể bạn sẽ thêm ở đây)
	# ...
	switch_turn()
	update_board()

func is_valid_move(index):
		# Người chơi 1 chỉ chọn ô 1 đến 5, người chơi 2 chọn 6 đến 10
	if current_player == 1 and index in range(1, 6):
		return cells[index] > 0
	elif current_player == 2 and index in range(6, 11):
		return cells[index] > 0
	return false

func switch_turn():
	current_player = 3 - current_player # Đảo qua lại giữa 1 và 2
