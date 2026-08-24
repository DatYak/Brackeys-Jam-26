class_name PickupTarget extends Node3D

var hover_target:bool = false
var dragging:bool= false
var follow_target:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _hover() -> void:
	print("Is target")
	hover_target = true

func _hover_end() -> void:
	print("Is no longer target")
	hover_target = false

func interact(cursor: Cursor):
	if hover_target:
		cursor.pick_up(self)

func _process(_delta: float) -> void:
	if dragging and follow_target:
		global_position = follow_target.global_position
