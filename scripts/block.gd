extends Area2D

signal block_clicked(block)

@export var block_color: Color

var row: int
var column: int

func _ready() -> void:
	$ColorRect.color = block_color
	input_pickable = true

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		block_clicked.emit(self)
