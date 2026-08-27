class_name BaseCamp extends Node3D

const TROOP_RADIUS = 1.8
const GENERAL_RADIUS = 5

signal _on_missions_completed

@onready var missionsParent : Node = $MissionLocations
@onready var generalDefaultLocation: Node3D = $GeneralsLocation
@onready var troopDefaultLocation : Node3D = $TroopsLocation
@export var troop_distance_apart : float = 2
@export var general_distance_apart : float = 4
@export var travel_time : float = 2

var missionScene = preload("res://scenes/mission.tscn")
var missionLocations : Array[Node3D] = []
var missions : Array[Mission] = []

func _ready() -> void:
	for node in missionsParent.get_children():
		if node is Node3D:
			missionLocations.append(node as Node3D)


func spawn_missions(missionsToSpawn : Array[MissionData]):
	for i in range(missionsToSpawn.size()):
		var mission : Mission = missionScene.instantiate() as Mission
		missions.append(mission)
		add_child(mission) 
		mission.global_position = missionLocations[i].global_position
		
		var data = missionsToSpawn[i]
		mission.skillRequired = data.skill_used
		mission.rewardType = data.success_reward
		mission.penaltyType = data.failure_penalty
		mission.mission_name = data.name
		mission.mission_description = data.description
		
		mission.skillCheck = data.skill_check
		
		
func exit_camp():
	for mission in missions:
		mission.queue_free()
	
	missions.clear()
	
func send_to_camp(_generals : Array[General], troops : Array[Troop]):	
	var num_troops = len(troops)
	var angle_inc = 360.0 / num_troops as float
	var angle = 0
	for i in range(troops.size()):
		var location_offset = Vector3(TROOP_RADIUS,0,0).rotated(Vector3.UP, deg_to_rad(angle))
		var new_location = troopDefaultLocation.global_position
		new_location+= location_offset
		troops[i].tween_global_position(new_location, travel_time)
		var tween = troops[i].tween_global_position(new_location, travel_time)
		tween.tween_callback(troops[i].pickupTarget.set_last_position)
		tween.tween_callback(troops[i].pickupTarget.reset)
		angle += angle_inc
		
	var num_generals = len(_generals)
	angle_inc = 360.0 / num_generals as float
	angle = 0

	for i in range(_generals.size()):
		var location_offset = Vector3(GENERAL_RADIUS,0,0).rotated(Vector3.UP, deg_to_rad(angle))
		var new_location = generalDefaultLocation.global_position
		new_location += location_offset
		_generals[i].tween_global_position(new_location, travel_time)
		var tween = _generals[i].tween_global_position(new_location, travel_time)
		tween.tween_callback(_generals[i].pickupTarget.set_last_position)
		tween.tween_callback(_generals[i].pickupTarget.reset)
		angle += angle_inc
		
func are_all_generals_assigned(_generalCount : int) -> bool:
	var generalsAssigned = 0
	for mission in missions:
		if (mission.dropoff.assigned_general != null):
			generalsAssigned += 1
			
	return generalsAssigned == _generalCount

func process_missions():
	
	for mission in missions:
		var general = mission.dropoff.assigned_general
		if (general != null):
			travel_to_mission(mission, general)
	
	pass

func travel_to_mission(mission : Mission, general : General):
	
	var general_starting_position : Vector3 = general.movement.global_position
	
	general.tween_global_position(mission.global_position, travel_time)
	var tween = get_tree().create_tween()
	tween.tween_property(general.pickupTarget.indicator, "global_position", general.pickupTarget.indicator.global_position, travel_time)
	
	for troop in general.party:
		troop.tween_global_position(mission.global_position + (troop.movement.global_position - general_starting_position), travel_time)
	
	await get_tree().create_timer(travel_time).timeout
	
	general.tween_global_position(general_starting_position, travel_time)
	for troop in general.party:
		troop.tween_global_position(general_starting_position + (troop.movement.global_position - general.movement.global_position), travel_time)
	
	perform_missions()
	await get_tree().create_timer(travel_time).timeout
	
	_on_missions_completed.emit()

func perform_missions():
	for mission:Mission in missions:
		if not mission.dropoff.is_occupied():
			continue
		var general = mission.dropoff.assigned_general
		mission.perform_mission(general, general.party)
