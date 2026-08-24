extends Node3D

var hover_target:bool = false
var dragging:bool= false

signal picked_up

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _hover() -> void:
	hover_target = true

func _hover_end() -> void:
	hover_target = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == 1:
		if event.is_pressed() and hover_target:
			dragging = true
			picked_up.emit()
