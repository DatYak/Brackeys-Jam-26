class_name GeneralDropoff extends Dropoff

@export var general:General
@export var troop_distance = 1.5

func _drop_entity(entity:PickupTarget) -> bool:
	var troop = entity.parent as Troop
	general.on_troop_entered_region(troop)
	print("Added troop to general")
	arrange_troops()
	return true

func _remove_entity(entity:PickupTarget) -> void:
	var troop = entity.parent as Troop
	general.on_troop_exited_region(troop)
	print("Removed troop from general")
	arrange_troops()

func arrange_troops() -> void:
	var num_troops = len(general.party)
	var angle_inc = 360.0 / num_troops as float
	var angle = 0
	for troop:Troop in general.party:
		var location = Vector3(troop_distance,1,0).rotated(Vector3.UP, deg_to_rad(angle))
		troop.pickupTarget.dragged_element.global_position = general.movement.global_position + location
		angle += angle_inc
	
