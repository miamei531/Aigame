extends Node2D
@onready var QuanXanh = $QuanXanh
@onready var QuanHong = $QuanHong
@onready var QuanXanhla = $"QuanXanhLá"
@onready var QuanVang = $"QuanVàng"
@onready var bgms =$AudioStreamPlayer
@onready var select_s =$select
@onready var change_turn = $change_turn
@onready var eat_sound = $an_quan
@onready var rai_quan = $rai_quan
@onready var selected = $selected
# === 1. HẰNG SỐ VÀ BIẾN TOÀN CỤC ===
var diff = 3
const CELL_SCENE := preload("res://oanquan/cell.tscn")
const PIECE_SCENE := preload("res://oanquan/piece.tscn")
var cells: Array[int] = [10, 5, 5, 5, 5, 5, 10, 5, 5, 5, 5, 5]
var cell_nodes: Array[Node] = []
var selected_index := 1
var current_player := 1
var waiting_for_direction := false
var score_p1 := 0
var score_p2 := 0
var debt_p1 := 0
var debt_p2 := 0
var pieces_by_cell := []  # Mỗi phần tử là một Array chứa các Piece của ô tương ứng
var is_playing := false
var select_pos= [
	Vector2(2,2),Vector2(341, 281),Vector2(458, 281),Vector2(576, 281),Vector2(693, 281),Vector2(809, 281),Vector2(2,2),
	Vector2(809, 389),Vector2(693, 389),Vector2(576, 389),Vector2(458, 389),Vector2(341, 389),
]
# === 2. KHỞI TẠO BÀN CHƠI ===
func _ready():
	diff = get_tree().get_meta("difficulty")
	if( diff==null):
		diff=3
	var screen_width = get_viewport_rect().size.x
	var screen_height = get_viewport_rect().size.y

	var cell_size = Vector2(100, 100)
	var spacing = 15
	var row_top_y = 220
	var row_bottom_y = 330

	# Tổng chiều rộng: 5 ô Dân + 2 ô Quan + khoảng cách
	var total_cells = 7   # 5 ô Dân + 2 Quan (xem như 7 ô dài)
	var total_width = total_cells * cell_size.x + (total_cells - 1) * spacing
	var start_x = (screen_width - total_width) / 2
	start_game()

	pieces_by_cell.resize(12)
	for i in range(12):
		pieces_by_cell[i] = []

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
				pos = Vector2(start_x + (i) * (cell_size.x + spacing), row_top_y)
			7,8,9,10,11:
				pos = Vector2(start_x + (12 - i) * (cell_size.x + spacing), row_bottom_y)
		cell.position = pos
		add_child(cell)
		cell_nodes.append(cell)
		_update_cell_label(cell, i)
		if i not in [0,6]:
			_spawn_pieces(cell_nodes[i],i)
		# Di chuyển Label xuống dưới nếu là ô 7-11
		if i in [7,8,9,10,11]:
			var label = cell.get_node("Label")
			if label:
				label.position.y += 160   # Dịch xuống dưới 30 pixels (tùy bạn điều chỉnh)
	_highlight_selected()
	_update_quan_visuals() 

# === 3. XỬ LÝ INPUT BÀN PHÍM ===
func _unhandled_input(event: InputEvent):
	if is_playing:
		return
	if event is InputEventKey and event.pressed:
		if not waiting_for_direction:
			if current_player == 2:
				if event.keycode == KEY_D:
					_move_selection(-1)
				elif event.keycode == KEY_A:
					_move_selection(1)
				elif event.keycode == KEY_S and _is_valid_move(selected_index):
					select_s.play()
					waiting_for_direction = true
			elif current_player == 1:
				if event.keycode == KEY_LEFT:
					_move_selection(-1)
				elif event.keycode == KEY_RIGHT:
					_move_selection(1)
				elif event.keycode == KEY_DOWN and _is_valid_move(selected_index):
					select_s.play()
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
	print(current_player)
	is_playing = true
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
		await _move_one_piece(cell_nodes[index], cell_nodes[idx])
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
				await _move_one_piece(cell_nodes[next_idx], cell_nodes[idx])
				_update_cell_label(cell_nodes[idx], idx)
				await get_tree().create_timer(0.5).timeout
		else:
			break
	# KIỂM TRA ĂN
	while true:
		var next = (idx + (1 if clockwise else -1) + 12) % 12
		var next_next = (next + (1 if clockwise else -1) + 12) % 12

		if cells[next] == 0 and cells[next_next] > 0 and next !=0 and next !=6: 
			if (next_next == 0 and QuanHong) or (next_next == 6 and QuanXanh):
				if cells[next_next] >= 15 :
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
	change_turn.play()
	_update_quan_visuals()
	# Kiểm tra kết thúc game tại đây
	if _is_game_over():
		_show_game_over()
		return
	# Cập nhật nếu còn chơi tiếp
	#if _has_no_moves():
		#_refill_cells()
	for i in range(12):
		_update_cell_label(cell_nodes[i], i)
	_auto_select_valid_cell()
	is_playing = false
	if current_player == 2:
		await ai_move()

# === 6. ĂN QUÂN ===
func _eat(i: int):
	eat_sound.play()
	#await get_tree().create_timer(eat_sound.stream.get_length()).timeout
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
		# Xóa toàn bộ quân trong ô đó
	if (i == 6):
		if QuanXanh:
			remove_child(QuanXanh)
			QuanXanh = null 
	if (i == 0):
		if QuanHong:
			remove_child(QuanHong)
			QuanHong = null 
	var area := cell_nodes[i].get_node("Area2D")
	for piece in pieces_by_cell[i]:
		area.remove_child(piece)
		piece.queue_free()
	pieces_by_cell[i].clear()
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

	# Cập nhật điểm hiển thị
	$diem1.text = str(score_p1)
	$diem2.text = str(score_p2)

	# Reset lại các ô dân với 1 quân và tạo quân mới
	for i in range(range_start, range_start + 5):
		cells[i] = 1
		_update_cell_label(cell_nodes[i], i)

		# Xoá quân cũ nếu còn (tránh trùng hình ảnh)
		var area = cell_nodes[i].get_node("Area2D")
		for piece in pieces_by_cell[i]:
			area.remove_child(piece)
			piece.queue_free()
		pieces_by_cell[i].clear()

		# Thêm quân mới
		_spawn_pieces(cell_nodes[i], i, 1)


# === 8. TỰ ĐỘNG CHỌN Ô ===
func _auto_select_valid_cell():
	if _has_no_moves():
		_refill_cells()
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
	selected.position= select_pos[selected_index]
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
	$Panel.visible=true

	var popup = Label.new()
	popup.text = "Trò chơi kết thúc!\n" + winner
	popup.position = Vector2(get_viewport_rect().size.x / 2 - 100, get_viewport_rect().size.y / 2 - 50)
	popup.set("theme_override_colors/font_color", Color.RED)
	popup.add_theme_font_size_override("font_size", 24)
	add_child(popup)

	# Ngăn không cho tiếp tục chơi
	set_process_unhandled_input(false)
# ĐỒ HỌA ỰAAAAAAAAAA
# SPAWN QUÂN LÚC BẮT ĐẦU
func _spawn_pieces(cell_node: Node, index: int, count: int = 5):
	var area := cell_node.get_node("Area2D")
	if not area:
		return
	var collision_shape := area.get_node("CollisionShape2D")
	if not collision_shape:
		return
	var shape = collision_shape.shape
	if shape is RectangleShape2D:
		var extents = shape.extents
		for i in range(count):  # <-- tạo đúng số quân
			var piece = PIECE_SCENE.instantiate()
			var offset = Vector2(
				randf_range(-extents.x, extents.x),
				randf_range(-extents.y, extents.y)
			)
			offset.y += 30
			piece.position = offset
			area.add_child(piece)
			pieces_by_cell[index].append(piece)
# RÃI QUÂN
func _move_one_piece(from_cell: Node, to_cell: Node) -> void:
	var from_index = from_cell.cell_index
	var to_index = to_cell.cell_index

	if pieces_by_cell[from_index].is_empty(): return

	var piece = pieces_by_cell[from_index].pop_back()
	var from_area = from_cell.get_node("Area2D")
	var to_area = to_cell.get_node("Area2D")

	from_area.remove_child(piece)
	add_child(piece)
	piece.global_position = from_area.global_position + piece.position
	var shape := to_area.get_node("CollisionShape2D").shape as RectangleShape2D
	if shape is RectangleShape2D:
		var offset = Vector2(
			randf_range(-shape.extents.x, shape.extents.x),
			randf_range(-shape.extents.y, shape.extents.y) + 30
		)
		var target = to_area.to_global(offset)

		await create_tween().tween_property(piece, "global_position", target, 0.25).finished
		rai_quan.play()
		remove_child(piece)
		to_area.add_child(piece)
		piece.position = to_area.to_local(target)
		pieces_by_cell[to_index].append(piece)
#---ĐỔI KÍCH THƯỚC QUAN MỖI LƯỢT---#
func _update_quan_visuals():
	var tween = create_tween()

	if current_player == 1:
		if QuanXanhla:
			tween.tween_property(QuanXanhla, "scale", Vector2(0.18, 0.15), 0.3)
			tween.tween_property(QuanXanhla, "modulate", Color(0, 1, 0, 1), 0.3)  # Xanh lá đậm
		if QuanVang:
			tween.tween_property(QuanVang, "scale", Vector2(0.141, 0.142), 0.3)
			tween.tween_property(QuanVang, "modulate", Color(1, 1, 1, 0.5), 0.3)
	else:
		if QuanXanhla:
			tween.tween_property(QuanXanhla, "scale", Vector2(0.135, 0.114), 0.3)
			tween.tween_property(QuanXanhla, "modulate", Color(1, 1, 1, 0.5), 0.3)
		if QuanVang:
			tween.tween_property(QuanVang, "scale", Vector2(0.17, 0.17), 0.3)
			tween.tween_property(QuanVang, "modulate", Color(1, 1, 0, 1), 0.3)  # Vàng đậm
func start_game():
	bgms.play()
	print("🔊 Hướng dẫn đã phát xong.")
# Hàm lượng giá (điểm số)
func _evaluate_state(cells_state: Array, score1: int, score2: int) -> int:
	return score2 - score1

# Kiểm tra game đã kết thúc chưa
func _is_terminal_state(cells_state: Array,score1: int, score2:int) -> bool:
	var side1_empty = true
	for i in range(1, 6):
		if cells_state[i] > 0:
			side1_empty = false
	var side2_empty = true
	for i in range(7, 12):
		if cells_state[i] > 0:
			side2_empty = false
	return (side1_empty and side2_empty) or ((score1+score2) <0)


# Hàm mô phỏng nước đi (trả về state mới)
func _simulate_move(
	cells_state: Array, index: int, clockwise: bool, is_ai: bool,
	score1: int, score2: int, Quanhongstate: bool, Quanxanhstate: bool
) -> Dictionary:
# refilllllllllllllllllllllll
	if( index < 6):
		var side_empty = true
		for i in range(1, 6):
			if cells_state[i] > 0:
				side_empty = false
		if side_empty:
			score1 -=5
			for i in range(1, 6):
				cells_state[i] =1
	else:
		var side_empty = true
		for i in range(7, 12):
			if cells_state[i] > 0:
				side_empty = false
		if side_empty:
			score2 -=5
			for i in range(7, 12):
				cells_state[i] =1
	
	
	var num = cells_state[index]
	cells_state[index] = 0
	var idx = index

	# Rải quân
	while num > 0:
		idx = (idx + (1 if clockwise else -1) + 12) % 12
		cells_state[idx] += 1
		num -= 1

	# Rải liên tiếp
	while true:
		var next_idx = (idx + (1 if clockwise else -1) + 12) % 12
		if cells_state[next_idx] > 0 and next_idx not in [0, 6]:
			num = cells_state[next_idx]
			cells_state[next_idx] = 0
			idx = next_idx
			while num > 0:
				idx = (idx + (1 if clockwise else -1) + 12) % 12
				cells_state[idx] += 1
				num -= 1
		else:
			break

	# Kiểm tra ăn
	while true:
		var next = (idx + (1 if clockwise else -1) + 12) % 12
		var next_next = (next + (1 if clockwise else -1) + 12) % 12

		if cells_state[next] == 0 and cells_state[next_next] > 0 and next != 0 and next != 6:
			if (next_next == 0 and Quanhongstate) or (next_next == 6 and Quanxanhstate):
				if cells_state[next_next] >= 15:
					var earned = cells_state[next_next]
					cells_state[next_next] = 0
					if is_ai:
						score2 += earned
					else:
						score1 += earned
					idx = next_next
					# Sau khi ăn quan thì quan mất
					if next_next == 0: Quanhongstate = false
					if next_next == 6: Quanxanhstate = false
				else:
					break
			else:
				var earned = cells_state[next_next]
				cells_state[next_next] = 0
				if is_ai:
					score2 += earned
				else:
					score1 += earned
				idx = next_next
		else:
			break

	# trả về state mới
	return {
		"cells": cells_state,
		"score1": score1,
		"score2": score2,
		"quanhong": Quanhongstate,
		"quanxanh": Quanxanhstate
	}


# Thuật toán Minimax
func _minimax(
	cells_state: Array, depth: int, maximizing: bool,
	score1: int, score2: int, Quanhongstate: bool, Quanxanhstate: bool , alpha: int , beta: int
) -> int:
	if depth == 0 or _is_terminal_state(cells_state,score1,score2):
		return _evaluate_state(cells_state, score1, score2)

	if maximizing: # lượt máy (AI side 7..11)
		var max_eval = -99999
		for i in range(7, 12):
			if cells_state[i] > 0:
				for clockwise in [true, false]:
					if alpha<=beta: 
						var new_cells = cells_state.duplicate()
						var res = _simulate_move(new_cells, i, clockwise, true,
							score1, score2, Quanhongstate, Quanxanhstate)
						var eval = _minimax(
							res["cells"], depth - 1, false,
							res["score1"], res["score2"],
							res["quanhong"], res["quanxanh"],
							alpha,beta
						)
						max_eval = max(max_eval, eval)
						alpha = max(alpha, max_eval)
		return max_eval
	else: # lượt người (Human side 1..5)
		var min_eval = 99999
		for i in range(1, 6):
			if cells_state[i] > 0:
				for clockwise in [true, false]:
					if alpha<=beta: 
						var new_cells = cells_state.duplicate()
						var res = _simulate_move(new_cells, i, clockwise, false,
							score1, score2, Quanhongstate, Quanxanhstate)
						var eval = _minimax(
							res["cells"], depth - 1, true,
							res["score1"], res["score2"],
							res["quanhong"], res["quanxanh"],
							alpha, beta
						)
						min_eval = min(min_eval, eval)
						beta = min(beta, min_eval)
		return min_eval


# AI chọn nước đi
func ai_move():
	var best_score = -99999
	var best_index = 7
	var best_dir = true
	var Quanhongstate = true if QuanHong else false
	var Quanxanhstate = true if QuanXanh else false
	var alpha =-99999
	var beta =99999
	print(diff)
	for i in range(7, 12):
		if cells[i] > 0:
			for clockwise in [true, false]:
				var new_cells = cells.duplicate()
				if alpha<=beta: 
					var res = _simulate_move(new_cells, i, clockwise, true, score_p1, score_p2, Quanhongstate, Quanxanhstate) 
					var eval = _minimax(
						res["cells"], diff, false,
						res["score1"], res["score2"],
						res["quanhong"], res["quanxanh"],
						alpha, beta
					)
					alpha = max(alpha,eval)

					if eval > best_score:
						best_score = eval
						best_index = i
						best_dir = clockwise

	await _play_turn(best_index, best_dir)
