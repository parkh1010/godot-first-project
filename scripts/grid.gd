extends Node2D

const COLUMNS = 8
const ROWS = 8
const CELL_SIZE = 64
const COLORS = [
	Color(1, 0, 0),
	Color(0, 0, 1),
	Color(0, 1, 0),
	Color(1, 1, 0),
]

var grid_data = []

const BlockScene = preload("res://scenes/Block.tscn")

func _ready() -> void:
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
	for row in range(ROWS):
		for column in range(COLUMNS):
			var color_index = grid_data[row][column]
			var block = BlockScene.instantiate()
			block.block_color = COLORS[color_index]
			block.position = Vector2(column * CELL_SIZE, row * CELL_SIZE)
			block.row = row
			block.column = column
			block.block_clicked.connect(_on_block_clicked)
			add_child(block)

func _on_block_clicked(block) -> void:
	print("클릭됨: ", block.row, ",", block.column)
