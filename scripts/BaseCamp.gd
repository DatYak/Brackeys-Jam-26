class_name BaseCamp extends Node3D

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
		mission.position = missionLocations[i].position
	
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
	
func send_to_camp(generals : Array[General], troops : Array[Troop]):
	
	for i in range(troops.size()):
		var new_location = troopDefaultLocation.global_position
		new_location.x += i * troop_distance_apart
		var tween = get_tree().create_tween()
		tween.tween_property(troops[i].movement, "global_position", new_location, travel_time) 
	
	for i in range(generals.size()):
		var new_location = generalDefaultLocation.global_position
		new_location.x += i * general_distance_apart
		var tween = get_tree().create_tween()
		tween.tween_property(generals[i].movement, "global_position", new_location, travel_time) 
