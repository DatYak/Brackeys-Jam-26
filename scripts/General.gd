class_name General extends Character

var party : Array[Troop] = []

signal troop_added_to_party(_troop: Troop)
signal troop_exited_party(_troop: Troop)

func on_troop_entered_region(_troop: Troop) -> void:
	_add_troop_to_party(_troop)

func on_troop_exited_region(_troop: Troop) -> void:
	_remove_troop_from_party(_troop)

func _add_troop_to_party(_troop: Troop) -> void:
	if (party.has(_troop)):
		return
	
	party.append(_troop)
	troop_added_to_party.emit(_troop)


func _remove_troop_from_party(_troop: Troop) -> void:
	if (not party.has(_troop)):
		return
	
	party.remove_at(party.find(_troop))
	troop_exited_party.emit(_troop)
	
