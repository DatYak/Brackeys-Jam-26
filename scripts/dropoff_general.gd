class_name GeneralDropoff extends Dropoff

@export var general:General

func _drop_entity(entity:PickupTarget) -> void:
	var troop = entity.parent as Troop
	general.on_troop_entered_region(troop)
	print("Added troop to general")

func _remove_entity(entity:PickupTarget) -> void:
	var troop = entity.parent as Troop
	general.on_troop_exited_region(troop)
	print("Removed troop from general")
