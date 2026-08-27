class_name Game extends Node

#maybe use this signal to activate some warning ui
signal _attempted_turn_process_without_assigned_generals

const AMOUNT_OF_TROOPS = 9
const STATS_TO_DISTRIBUTE = 50
const MIN_STATS_PER_TROOP = 3

const MIN_STAT_VALUE = 0
const MAX_STAT_VALUE = 4
const STAT_COUNT = 3

const LOYALTY_TO_DISTRIBUTE = 65
const MIN_LOYALTY_PER_TROOP = 3

const NUM_GENERALS = 3
const LOYAL_GENERAL_STATS = 2
const SKILLED_GENERAL_STATS = 10
const DISLOYAL_GENERAL_STATS = 6

const LOYAL_GENERAL_LOYALTY = CharacterStats.MAX_LOYALTY
const SKILLED_GENERAL_LOYALTY = 4
const DISLOYAL_GENERAL_LOYALTY = 0

const NUM_MISSIONS_PRESENTED = 3
# Missions are on average 60% of max diffuculty
const AVERAGE_MISSION_DIFFICULTY = .6
const FAVOR_PER_BOON = 3

var troopScene = preload("res://scenes/troop.tscn")
var generalScene = preload("res://scenes/general.tscn")
var player_scene = preload("res://scenes/player.tscn")

var allTroops : Array[Troop] = []
var allGenerals: Array[General] = []
var player:Player

@export var general_icons:Array[Texture2D]
@export var troop_icon:Texture2D

var boons = 0

@onready var camera : CameraController = $InteractiveMap/Camera3D
@onready var baseCampCollectionsParent : Node = $InteractiveMap/BaseCampCollections
static var instance : Game = self

var baseCampCollectionsByBoon : Array[BaseCampCollection] = []
var currentBaseCampIndex = 0
var activeBaseCamp : BaseCamp
var are_missions_active = false

signal _on_supplies_found (supplies: int)
signal _on_favor_earned (favor: int)
signal _on_boon_earned
var boon_earned_last_mission = false

var missionDatabase : MissionCSVParser
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	
	missionDatabase = MissionCSVParser.new()
	missionDatabase.loadData()
	
	spawn_troops(AMOUNT_OF_TROOPS, STATS_TO_DISTRIBUTE, MIN_STATS_PER_TROOP, LOYALTY_TO_DISTRIBUTE, MIN_LOYALTY_PER_TROOP)
	spawn_generals()
	player = player_scene.instantiate() as Player
	add_child(player)
	player.game = self
	
	_on_supplies_found.connect(player.add_supplies)
	_on_favor_earned.connect(player.add_favor)
	
	for node in baseCampCollectionsParent.get_children():
		if node is BaseCampCollection:
			baseCampCollectionsByBoon.append(node as BaseCampCollection)
	
	boon_earned_last_mission = true
	move_to_new_base_camp()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("next_turn") and not are_missions_active:
		process_turn()

func process_turn()-> void:

	#Check if all generals are assigned...
	if (not activeBaseCamp.are_all_generals_assigned(NUM_GENERALS)):
		print("Must assign all generals first.")
		_attempted_turn_process_without_assigned_generals.emit()
		return
	
	are_missions_active = true
	# Process Missions
	activeBaseCamp.process_missions()

# Called via signal from activeBaseCamp
func on_missions_completed() -> void:
	
	#cleanup
	for troop:Character in allTroops:
		troop.pickupTarget.reset()
		
	for troop:Character in allGenerals:
		troop.pickupTarget.reset()
	
	
	# start next turn
	are_missions_active = false

	player.expend_turn_supplies()
	move_to_new_base_camp()

func move_to_new_base_camp() -> void:
	
	if (activeBaseCamp != null):
		activeBaseCamp.exit_camp()
		activeBaseCamp._on_missions_completed.disconnect(on_missions_completed)
	
	if (boon_earned_last_mission):
		boon_earned_last_mission = false
		currentBaseCampIndex = 0
	else:
		currentBaseCampIndex += 1
		currentBaseCampIndex %= baseCampCollectionsByBoon[boons].contents.size()
	
	activeBaseCamp = baseCampCollectionsByBoon[boons].contents[currentBaseCampIndex]
	activeBaseCamp._on_missions_completed.connect(on_missions_completed)
	
	activeBaseCamp.spawn_missions(getNewMissionData())
	activeBaseCamp.send_to_camp(allGenerals, allTroops)
	camera.center_on_point(activeBaseCamp.position)

func getNewMissionData() -> Array[MissionData]:
	
	var missionData : Array[MissionData] = []
	
	var total_difficulty:int = ceili((NUM_MISSIONS_PRESENTED * AVERAGE_MISSION_DIFFICULTY) * Mission.MAX_SKILL_CHECK)
	var max_diff = Mission.MAX_SKILL_CHECK
	var min_diff = Mission.MIN_SKILL_CHECK
	
	for i in range(NUM_MISSIONS_PRESENTED):
		var skillCheck = randi_range(min_diff, max_diff)
		
		var difficultyConversion = ceili(3 * (skillCheck-min_diff ) as float / (max_diff-min_diff) as float) - 1 #converts to an int: 0, 1, 2
		var newMissionData = missionDatabase.get_random_mission_by_difficulty(difficultyConversion)
		
		newMissionData.skill_check = skillCheck
		missionData.append(newMissionData)
		total_difficulty -= skillCheck
		max_diff = max(max_diff, total_difficulty)
		
	return missionData

## Get the number of units (troops + generals)
func get_unit_count() -> int:
	return len(allGenerals) + len(allTroops)

func spawn_troops(amount : int, statsToDistribute : int, minStatsPerTroop: int, loyaltyToDistribute : int, minLoyaltyPerTroop : int):
	if statsToDistribute < minStatsPerTroop * amount:
		print("Can't meet min stats per troop with requested variables.")
	
	var maxStatsPerTroop = MAX_STAT_VALUE * STAT_COUNT
	if statsToDistribute > maxStatsPerTroop * amount:
		print("Too many stats to distribute. Aborting spawn to prevent loop.")
		return
	
	if loyaltyToDistribute < minLoyaltyPerTroop * amount:
		print("Can't meet min loyalty per troop with requested variables.")
	
	if (loyaltyToDistribute > CharacterStats.MAX_LOYALTY * amount):
		print("Too much loyalty to distribute. Aborting spawn to prevent loop.")
		return
	
	var statsPerTroop : Array[int] = []
	var loyaltyPerTroop : Array[int] = []
	
	for i in range(amount):
		var troop:Troop = troopScene.instantiate()
		allTroops.append(troop)
		statsPerTroop.append(minStatsPerTroop)
		loyaltyPerTroop.append(minLoyaltyPerTroop)
		
		add_child(troop)
		troop.movement.position.x = i
		troop.movement.position.y = 1
		troop.pickupTarget.set_initial_position()
	
	for i in range(statsToDistribute - (minStatsPerTroop * amount)):
		var randomIndex = randi() % amount
		while (statsPerTroop[randomIndex] >= maxStatsPerTroop):
			randomIndex = randi() % amount
		statsPerTroop[randomIndex] += 1
	
	for i in range(loyaltyToDistribute - (minLoyaltyPerTroop * amount)):
		var randomIndex = randi() % amount
		while (loyaltyPerTroop[randomIndex] >= CharacterStats.MAX_LOYALTY):
			randomIndex = randi() % amount
		loyaltyPerTroop[randomIndex] += 1
	
	for i in range(amount):
		assign_stats_and_loyalty(allTroops[i], statsPerTroop[i], loyaltyPerTroop[i])

func spawn_generals() -> void:
	
	var stats = [LOYAL_GENERAL_STATS, SKILLED_GENERAL_STATS, DISLOYAL_GENERAL_STATS]
	var loyalty = [LOYAL_GENERAL_LOYALTY, SKILLED_GENERAL_LOYALTY, DISLOYAL_GENERAL_LOYALTY]
	
	for i in range(NUM_GENERALS):
		var general:General = generalScene.instantiate()
		allGenerals.append(general)	
		add_child(general)
		general.movement.position = Vector3(i * 5, 1, 5)
		general.pickupTarget.set_initial_position() 
		general.assign_image(general_icons[i])
		
		var random = randi() % stats.size()
		assign_stats_and_loyalty(general, stats[random], loyalty[random])
		stats.remove_at(random)
		loyalty.remove_at(random)
		

func assign_stats_and_loyalty(character : Character, totalStats: int, loyalty: int):
	if totalStats > MAX_STAT_VALUE * STAT_COUNT:
		print("Too many stats to allocate.")
		return
	
	var stats : Array[int]
	for i in range(STAT_COUNT):
		stats.append(MIN_STAT_VALUE)
	
	totalStats -= MIN_STAT_VALUE * STAT_COUNT
	
	for i in range(totalStats):
		var stat = randi() % STAT_COUNT
		while (stats[stat] >= MAX_STAT_VALUE):
			stat = randi() % STAT_COUNT
		stats[stat] += 1
	
	character.stats.set_stats(stats[0], stats[1], stats[2], loyalty)

func on_boon_earned() -> void:
	print ("Boon earned")
	boons += 1
	boon_earned_last_mission = true

func on_supplies_empty() -> void:
	#LOSE
	print("Game OVER!")
