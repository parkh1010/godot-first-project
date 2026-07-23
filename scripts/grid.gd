extends Node2D

const COLUMNS = 8
const ROWS = 8
const CELL_SIZE = 130
const ANIMAL_TEXTURES = [
	preload("res://assets/animals/panda.png"),
	preload("res://assets/animals/parrot.png"),
	preload("res://assets/animals/pig.png"),
	preload("res://assets/animals/snake.png"),
	preload("res://assets/animals/giraffe.png"),
]

var grid_data = []
var block_nodes = []
var score = 0
var time_left = 60.0
var game_over = false
var processing_click: bool = false

const BlockScene = preload("res://scenes/Block.tscn")

func _ready() -> void:
	var grid_width = COLUMNS * CELL_SIZE
	var grid_height = ROWS * CELL_SIZE
	var center_x = (1080 - grid_width) / 2
	var center_y = (1920 - grid_height) / 2
	position = Vector2(center_x, center_y)

	_fill_grid_data()
	_spawn_blocks()

func _process(delta: float) -> void:
	if not game_over:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			game_over = true
			print("게임 종료! 최종 점수: ", score)

	get_node("../UI/TimerBar").value = time_left
	get_node("../UI/TimerLabel").text = str(int(ceil(time_left)))

func _fill_grid_data() -> void:
	grid_data = []
	for row in range(ROWS):
		var row_data = []
		for column in range(COLUMNS):
			row_data.append(randi() % ANIMAL_TEXTURES.size())
		grid_data.append(row_data)

func _spawn_blocks() -> void:
	block_nodes = []
	for row in range(ROWS):
		var row_nodes = []
		for column in range(COLUMNS):
			var color_index = grid_data[row][column]
			var block = BlockScene.instantiate()
			block.animal_texture = ANIMAL_TEXTURES[color_index]
			block.position = Vector2(column * CELL_SIZE, row * CELL_SIZE)
			block.row = row
			block.column = column
			block.block_clicked.connect(_on_block_clicked)
			add_child(block)
			row_nodes.append(block)
		block_nodes.append(row_nodes)

func _on_block_clicked(block) -> void:
	if game_over:
		return
	var connected = _find_connected_blocks(block.row, block.column)
	if connected.size() < 3:
		score -= 10
		get_node("../UI/ScoreLabel").text = str(score)
		print("3개 미만 클릭 - 10점 감점, 현재 점수: ", score)
		return

	processing_click = true

	for coord in connected:
		var r = coord[0]
		var c = coord[1]
		if block_nodes[r][c] == null:
			continue
		block_nodes[r][c].play_pop_animation()
	await get_tree().create_timer(0.25).timeout

	for coord in connected:
		var r = coord[0]
		var c = coord[1]
		if block_nodes[r][c] == null:
			continue
		block_nodes[r][c].queue_free()
		block_nodes[r][c] = null
		grid_data[r][c] = -1

	await _apply_gravity()
	_refill_empty_cells()

	score += connected.size() * 10
	get_node("../UI/ScoreLabel").text = str(score)

	print(connected.size(), "개 제거됨")

	processing_click = false

func _apply_gravity() -> void:
	var tweens = []
	for column in range(COLUMNS):
		var write_row = ROWS - 1
		for row in range(ROWS - 1, -1, -1):
			if grid_data[row][column] == -1:
				continue
			if write_row != row:
				grid_data[write_row][column] = grid_data[row][column]
				grid_data[row][column] = -1

				var block = block_nodes[row][column]
				block_nodes[write_row][column] = block
				block_nodes[row][column] = null
				block.row = write_row

				var target_position = Vector2(column * CELL_SIZE, write_row * CELL_SIZE)
				var tween = create_tween()
				tween.set_ease(Tween.EASE_OUT)
				tween.set_trans(Tween.TRANS_QUAD)
				tween.tween_property(block, "position", target_position, 0.5)
				tweens.append(tween)
			write_row -= 1

	for tween in tweens:
		await tween.finished

func _refill_empty_cells() -> void:
	for row in range(ROWS):
		for column in range(COLUMNS):
			if grid_data[row][column] != -1:
				continue

			var color_index = randi() % ANIMAL_TEXTURES.size()
			grid_data[row][column] = color_index

			var block = BlockScene.instantiate()
			block.animal_texture = ANIMAL_TEXTURES[color_index]
			block.position = Vector2(column * CELL_SIZE, row * CELL_SIZE)
			block.row = row
			block.column = column
			block.block_clicked.connect(_on_block_clicked)
			add_child(block)
			block_nodes[row][column] = block

func _find_connected_blocks(row: int, col: int) -> Array:
	var target_color = grid_data[row][col]
	var visited = {}
	var result = []
	var queue = [[row, col]]
	visited[[row, col]] = true

	while queue.size() > 0:
		var current = queue.pop_front()
		var r = current[0]
		var c = current[1]
		result.append(current)

		var neighbors = [[r - 1, c], [r + 1, c], [r, c - 1], [r, c + 1]]
		for neighbor in neighbors:
			var nr = neighbor[0]
			var nc = neighbor[1]
			if nr < 0 or nr >= ROWS or nc < 0 or nc >= COLUMNS:
				continue
			if visited.has(neighbor):
				continue
			if grid_data[nr][nc] != target_color:
				continue
			visited[neighbor] = true
			queue.append(neighbor)

	return result
