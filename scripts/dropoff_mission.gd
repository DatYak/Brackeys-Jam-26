class_name MissionDropoff extends Dropoff

@onready var mission:Mission = $".."

var assigned_general:General = null

func is_occupied() -> bool:
	if assigned_general == null:
		return false
	return true

func _drop_entity(entity:PickupTarget) -> bool:
	if is_occupied():
		return false
		
	assigned_general = entity.parent as General
	return true
	

func _remove_entity(entity:PickupTarget) -> void:
	assigned_general = null
