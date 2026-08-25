class_name PickupTarget extends Node3D

@export var pickup_phase:int = 0
@onready var parent:Node = self.get_parent().get_parent()

var hover_target:bool = false
var dragging:bool= false
var follow_target:Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _hover() -> void:
	# print("Hovering:" + get_parent().get_parent().name)
	hover_target = true

func _hover_end() -> void:
	hover_target = false

func interact(cursor: Cursor, interact_phase: int) -> void:
	if hover_target:
		if interact_phase == pickup_phase:
			cursor.pick_up(self)
			on_pick_up(interact_phase)

func on_pick_up(interact_phase:int)->void:
	for area:Node in $Area3D.get_overlapping_areas():
		if area.is_in_group("Dropoff"):
			var dropoff = area.get_parent() as Dropoff
			if dropoff.interact_phase == interact_phase:
				dropoff._remove_entity(self)
				break;

func on_place(interact_phase:int) -> void:
	for area in $Area3D.get_overlapping_areas():
		if area.is_in_group("Dropoff"):
			var dropoff = area.get_parent() as Dropoff
			if dropoff.interact_phase == interact_phase:
				dropoff._drop_entity(self)
				break

func _process(_delta: float) -> void:
	if dragging and follow_target:
		get_parent_node_3d().global_position = follow_target.global_position
