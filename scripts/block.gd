extends Area2D

signal block_clicked(block)

@export var animal_texture: Texture2D

var row: int
var column: int

func _ready() -> void:
	$AnimalIcon.texture = animal_texture
	input_pickable = true

func play_pop_animation() -> void:
	$AnimationPlayer.play("pop")
	await $AnimationPlayer.animation_finished

func _input_event(viewport: Viewport, event: InputEvent, shape_idx: int) -> void:
	var is_mouse_click = event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	var is_touch = event is InputEventScreenTouch and event.pressed
	if is_mouse_click or is_touch:
		block_clicked.emit(self)
