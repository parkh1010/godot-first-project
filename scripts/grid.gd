extends Node2D

const COLUMNS = 8
const ROWS = 8
const CELL_SIZE = 130
const COLORS = [
	Color(1, 0, 0),
	Color(0, 0, 1),
	Color(0, 1, 0),
	Color(1, 1, 0),
]

var grid_data = []
var block_nodes = []

const BlockScene = preload("res://scenes/Block.tscn")

func _ready() -> void:
	var grid_width = COLUMNS * CELL_SIZE
	var grid_height = ROWS * CELL_SIZE
	var center_x = (1080 - grid_width) / 2
	var center_y = (1920 - grid_height) / 2
	position = Vector2(center_x, center_y)

	_fill_grid_data()
	_spawn_blocks()

func _fill_grid_data() -> void:
	grid_data = []
	for row in range(ROWS):
		var row_data = []
		for column in range(COLUMNS):
			row_data.append(randi() % COLORS.size())
		grid_data.append(row_data)

func _spawn_blocks() -> void:
	block_nodes = []
	for row in range(ROWS):
		var row_nodes = []
		for column in range(COLUMNS):
			var color_index = grid_data[row][column]
			var block = BlockScene.instantiate()
			block.block_color = COLORS[color_index]
			block.position = Vector2(column * CELL_SIZE, row * CELL_SIZE)
			block.row = row
			block.column = column
			block.block_clicked.connect(_on_block_clicked)
			add_child(block)
			row_nodes.append(block)
		block_nodes.append(row_nodes)

func _on_block_clicked(block) -> void:
	var connected = _find_connected_blocks(block.row, block.column)
	if connected.size() < 3:
		print("3개 미만이라 무시됨")
		return

	for coord in connected:
		var r = coord[0]
		var c = coord[1]
		block_nodes[r][c].queue_free()
		block_nodes[r][c] = null
		grid_data[r][c] = -1

	_apply_gravity()
	_refill_empty_cells()

	print(connected.size(), "개 제거됨")

func _apply_gravity() -> void:
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
				block.position = Vector2(column * CELL_SIZE, write_row * CELL_SIZE)
			write_row -= 1

func _refill_empty_cells() -> void:
	for row in range(ROWS):
		for column in range(COLUMNS):
			if grid_data[row][column] != -1:
				continue

			var color_index = randi() % COLORS.size()
			grid_data[row][column] = color_index

			var block = BlockScene.instantiate()
			block.block_color = COLORS[color_index]
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
