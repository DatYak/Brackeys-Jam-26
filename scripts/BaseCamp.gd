class_name BaseCamp extends Node3D

signal _on_missions_completed

@onready var missionsParent : Node = $MissionLocations
@onready var generalDefaultLocation: Node3D = $GeneralsLocation
@onready var troopDefaultLocation : Node3D = $TroopsLocation
@export var troop_distance_apart = 2
@export var general_distance_apart = 4
@export var travel_time = 2

var missionScene = preload("res://scenes/mission.tscn")
var missionLocations : Array[Node3D] = []
var missions : Array[Mission] = []

func _ready() -> void:
	for node in missionsParent.get_children():
		if node is Node3D:
			missionLocations.append(node as Node3D)
			
func spawn_missions(missionCount : int, averageDifficulty : int) -> Array[Mission]:
	
	for i in range(missionCount):
		var mission : Mission = missionScene.instantiate() as Mission
		missions.append(mission)
		add_child(mission) 
		mission.global_position = missionLocations[i].global_position
	
	var total_difficulty:int = ceili((missionCount * averageDifficulty) * Mission.MAX_SKILL_CHECK)
	var max_diff = Mission.MAX_SKILL_CHECK
	var min_diff = Mission.MIN_SKILL_CHECK
	for mission in missions:
		var difficulty = randi_range(min_diff, max_diff)
		mission.skillCheck = difficulty
		total_difficulty -= difficulty
		max_diff = max(max_diff, total_difficulty)
		mission.rewardType = Mission.MissionRewardType.values().pick_random()
		mission.penaltyType = Mission.MissionPenaltyType.values().pick_random()
	
	return missions

func exit_camp():
	for mission in missions:
		mission.queue_free()
	
	missions.clear()
	
func send_to_camp(_generals : Array[General], troops : Array[Troop]):	
	for i in range(troops.size()):
		var new_location = troopDefaultLocation.global_position
		new_location.x += i * troop_distance_apart
		troops[i].tween_global_position(new_location, travel_time)

	for i in range(_generals.size()):
		var new_location = generalDefaultLocation.global_position
		new_location.x += i * general_distance_apart
		_generals[i].tween_global_position(new_location, travel_time)

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
	for troop in general.party:
		troop.tween_global_position(mission.global_position + (general_starting_position - troop.movement.global_position), travel_time)
	
	await get_tree().create_timer(travel_time).timeout
	
	general.tween_global_position(general_starting_position, travel_time)
	for troop in general.party:
		troop.tween_global_position(general_starting_position + (general.movement.global_position - troop.movement.global_position), travel_time)
	
	perform_missions()
	await get_tree().create_timer(travel_time).timeout
	
	_on_missions_completed.emit()

func perform_missions():
	for mission:Mission in missions:
		if not mission.dropoff.is_occupied():
			continue
		var general = mission.dropoff.assigned_general
		mission.perform_mission(general, general.party)
