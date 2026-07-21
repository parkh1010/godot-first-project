extends Area2D

@export var block_color: Color

func _ready() -> void:
	$ColorRect.color = block_color
