class_name MissionDropoff extends Dropoff

@onready var mission:Mission = $".."
@onready var ui:MissionUI = $"../MissionInspectUi"

var assigned_general:General = null

func is_occupied() -> bool:
	if assigned_general == null:
		return false
	return true

func _drop_entity(entity:PickupTarget) -> bool:
	if is_occupied():
		return false
	
	assigned_general = entity.parent as General
	entity.dragged_element.global_position = global_position + Vector3.UP * 1.5
	assigned_general.troop_added_to_party.connect(ui.display)
	assigned_general.pickupTarget.area3d.global_position = global_position
	return true

func _remove_entity(entity:PickupTarget) -> void:
	if assigned_general:
		assigned_general.troop_added_to_party.disconnect(ui.display)
	assigned_general = null

func _hover() -> void:
	ui.display()
	ui.visible = true

func _hover_end() -> void:
	ui.visible = false
