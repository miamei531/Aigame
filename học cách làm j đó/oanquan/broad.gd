extends Node2D

# === 1. HẰNG SỐ VÀ BIẾN TOÀN CỤC ===
const CELL_SCENE := preload("res://oanquan/cell.tscn")

var cells: Array[int] = [0, 5, 5, 5, 5, 5, 0, 5, 5, 5, 5, 5]
var cell_nodes: Array[Node] = []
var selected_index := 1
var current_player := 1
var waiting_for_direction := false
var score_p1 := 0
var score_p2 := 0
var debt_p1 := 0
var debt_p2 := 0


# === 2. KHỞI TẠO BÀN CHƠI ===
func _ready():
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y

	var cell_size = Vector2(100, 100)
	var spacing = 10

	var row_top_y = 220
	var row_bottom_y = 330

	# Tổng chiều rộng: 5 ô Dân + 2 ô Quan + khoảng cách
	var total_cells = 7   # 5 ô Dân + 2 Quan (xem như 7 ô dài)
	var total_width = total_cells * cell_size.x + (total_cells - 1) * spacing
	var start_x = (screen_width - total_width) / 2

	for i in range(12):
		var cell = CELL_SCENE.instantiate()
		cell.cell_index = i
		var pos = Vector2()

		match i:
			0:  # Quan trái
				pos = Vector2(start_x, (row_top_y + row_bottom_y) / 2)
			6:  # Quan phải
				pos = Vector2(start_x + 6 * (cell_size.x + spacing), (row_top_y + row_bottom_y) / 2)
			1,2,3,4,5:
				pos = Vector2(start_x + (i) * (cell_size.x + spacing), row_bottom_y)
			7,8,9,10,11:
				pos = Vector2(start_x + (12 - i) * (cell_size.x + spacing), row_top_y)

		cell.position = pos
		add_child(cell)
		cell_nodes.append(cell)
		_update_cell_label(cell, i)

	_highlight_selected()

# === 3. XỬ LÝ INPUT BÀN PHÍM ===
func _unhandled_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if not waiting_for_direction:
			if current_player == 2:
				if event.keycode == KEY_D:
					_move_selection(-1)
				elif event.keycode == KEY_A:
					_move_selection(1)
				elif event.keycode == KEY_S and _is_valid_move(selected_index):
					waiting_for_direction = true
			elif current_player == 1:
				if event.keycode == KEY_LEFT:
					_move_selection(-1)
				elif event.keycode == KEY_RIGHT:
					_move_selection(1)
				elif event.keycode == KEY_DOWN and _is_valid_move(selected_index):
					waiting_for_direction = true
		else:
			if event.keycode == KEY_UP or event.keycode == KEY_W:
				waiting_for_direction = false
			elif (event.keycode == KEY_D and current_player == 2) or (event.keycode == KEY_LEFT and current_player == 1):
				await _play_turn(selected_index, false)
				waiting_for_direction = false
			elif (event.keycode == KEY_A and current_player == 2) or (event.keycode == KEY_RIGHT and current_player == 1):
				await _play_turn(selected_index, true)
				waiting_for_direction = false

# === 4. DI CHUYỂN CON TRỎ CHỌN Ô ===
func _move_selection(offset: int):
	for _i in range(12):
		selected_index = (selected_index + offset + 12) % 12
		if _is_valid_move(selected_index):
			break
	_highlight_selected()

# === 5. CHƠI MỘT LƯỢT ===
func _play_turn(index: int, clockwise: bool) -> void:
	# Nếu game chưa kết thúc thì bắt đầu lượt chơi
	var num = cells[index]
	cells[index] = 0
	var idx = index
	_update_cell_label(cell_nodes[idx], idx)

	# RẢI QUÂN CÓ HIỆU ỨNG
	while num > 0:
		idx = (idx + (1 if clockwise else -1) + 12) % 12
		cells[idx] += 1
		num -= 1
		_update_cell_label(cell_nodes[idx], idx)
		await get_tree().create_timer(0.5).timeout
	# NẾU Ô TIẾP THEO CÓ QUÂN 
	while true:
		var next_idx = (idx + (1 if clockwise else -1) + 12) % 12
		if cells[next_idx] > 0 and next_idx !=0 and next_idx !=6:
			num = cells[next_idx]
			cells[next_idx] = 0
			_update_cell_label(cell_nodes[next_idx], next_idx)
			idx = next_idx
			while num > 0:
				idx = (idx + (1 if clockwise else -1) + 12) % 12
				cells[idx] += 1
				num -= 1
				_update_cell_label(cell_nodes[idx], idx)
				await get_tree().create_timer(0.5).timeout
		else:
			break
	# KIỂM TRA ĂN
	while true:
		var next = (idx + (1 if clockwise else -1) + 12) % 12
		var next_next = (next + (1 if clockwise else -1) + 12) % 12

		if cells[next] == 0 and cells[next_next] > 0 and next !=0 and next !=6: 
			if next_next == 0 or next_next == 6:
				if cells[next_next] >= 5:
					_eat(next_next)
					idx = next_next
				else:
					break
			else:
				_eat(next_next)
				idx = next_next
		else:
			break
	
	current_player = 2 if current_player == 1 else 1
	# Kiểm tra kết thúc game tại đây
	if _is_game_over():
		_show_game_over()
		return
	# Cập nhật nếu còn chơi tiếp
	if _has_no_moves():
		_refill_cells()
	for i in range(12):
		_update_cell_label(cell_nodes[i], i)
	_auto_select_valid_cell()

# === 6. ĂN QUÂN ===
func _eat(i: int):
	var earned = cells[i]
	cells[i] = 0

	if current_player == 1:
		var repay = min(debt_p1, earned)
		debt_p1 -= repay
		score_p1 += earned - repay
	else:
		var repay = min(debt_p2, earned)
		debt_p2 -= repay
		score_p2 += earned - repay

	$diem1.text = str(score_p1)
	$diem2.text = str(score_p2)
	_update_cell_label(cell_nodes[i], i)
	
# === 7. HẾT QUÂN PHẢI RẢI LẠI ===
func _has_no_moves() -> bool:
	var range_start = 1 if current_player == 1 else 7
	for i in range(range_start, range_start + 5):
		if cells[i] > 0:
			return false
	return true

func _refill_cells():
	var range_start = 1 if current_player == 1 else 7
	var score_ref = score_p1 if current_player == 1 else score_p2
	if score_ref < 5:
		var borrow = 5 - score_ref
		if current_player == 1:
			debt_p1 += borrow
			score_p1 = 0
			score_p2 = max(score_p2 - borrow, 0)
		else:
			debt_p2 += borrow
			score_p2 = 0
			score_p1 = max(score_p1 - borrow, 0)
	else:
		if current_player == 1:
			score_p1 -= 5
		else:
			score_p2 -= 5

	$diem1.text = str(score_p1)
	$diem2.text = str(score_p2)
	for i in range(range_start, range_start + 5):
		cells[i] = 1
		_update_cell_label(cell_nodes[i], i)


# === 8. TỰ ĐỘNG CHỌN Ô ===
func _auto_select_valid_cell():
	var range_start = 1 if current_player == 1 else 7
	for i in range(range_start, range_start + 5):
		if _is_valid_move(i):
			selected_index = i
			_highlight_selected()
			return

# === 9. KIỂM TRA Ô HỢP LỆ ===
func _is_valid_move(index: int) -> bool:
	if index == 0 or index == 6:
		return false
	if current_player == 1 and index >= 1 and index <= 5:
		return cells[index] > 0
	elif current_player == 2 and index >= 7 and index <= 11:
		return cells[index] > 0
	return false

# === 10. CẬP NHẬT GIAO DIỆN ===
func _update_cell_label(cell_node: Node, i: int):
	var label = cell_node.get_node("Label")
	if label:
		label.text = str(cells[i])
		label.modulate = Color.BLACK

# === 11. TÔ SÁNG Ô ===
func _highlight_selected():
	for i in range(12):
		var label = cell_nodes[i].get_node("Label")
		if label:
			label.modulate = Color.BLACK
	if cell_nodes[selected_index]:
		var label = cell_nodes[selected_index].get_node("Label")
		if label:
			label.modulate = Color.RED
# === KẾT GAME===
func _is_game_over() -> bool:
	# Nếu cả hai ô quan đều trống
	if cells[0] == 0 and cells[6] == 0:
		return true
	# Cả hai người chơi không còn quân để đi
	var check= true
	for i in range(5):
		if cells[1 + i] > 0 or cells[7 + i] > 0:
			check = false
	if check:
		return true
	# Nếu một người chơi không còn quân, người còn lại không thể cho mượn nữa
	if _has_no_moves():
		var score_ref = score_p1 + score_p2
		if score_ref < 5:
			return true
	return false
func _show_game_over():
	var winner = ""
	if score_p1 > score_p2:
		winner = "Người chơi 1 thắng!"
	elif score_p2 > score_p1:
		winner = "Người chơi 2 thắng!"
	else:
		winner = "Hòa!"

	var popup = Label.new()
	popup.text = "Trò chơi kết thúc!\n" + winner
	popup.position = Vector2(get_viewport_rect().size.x / 2 - 100, get_viewport_rect().size.y / 2 - 50)
	popup.set("theme_override_colors/font_color", Color.RED)
	popup.add_theme_font_size_override("font_size", 24)
	add_child(popup)

	# Ngăn không cho tiếp tục chơi
	set_process_unhandled_input(false)
