class_name Dropoff extends Node3D

@export var interact_type:Cursor.CursorTarget

func _drop_entity(entity:PickupTarget) -> bool:
	return true

func _remove_entity(entity:PickupTarget) -> void:
	pass
