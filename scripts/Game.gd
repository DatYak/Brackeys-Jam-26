class_name Game extends Node

const AMOUNT_OF_TROOPS = 9
const STATS_TO_DISTRIBUTE = 50
const MIN_STATS_PER_TROOP = 3

const MIN_STAT_VALUE = 0
const MAX_STAT_VALUE = 4
const STAT_COUNT = 3

const LOYALTY_TO_DISTRIBUTE = 65
const MIN_LOYALTY_PER_TROOP = 3
const MAX_LOYALTY_PER_TROOP = 10

const LOYAL_GENERAL_STATS = 2
const SKILLED_GENERAL_STATS = 10
const DISLOYAL_GENERAL_STATS = 6

const LOYAL_GENERAL_LOYALTY = 10
const SKILLED_GENERAL_LOYALTY = 5
const DISLOYAL_GENERAL_LOYALTY = 0

var troopScene = preload("res://scenes/troop.tscn")
var generalScene = preload("res://scenes/general.tscn")
var allTroops : Array[Troop] = []
var allGenerals: Array[General] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_troops(AMOUNT_OF_TROOPS, STATS_TO_DISTRIBUTE, MIN_STATS_PER_TROOP, LOYALTY_TO_DISTRIBUTE, MIN_LOYALTY_PER_TROOP)
	spawn_generals()

func spawn_troops(amount : int, statsToDistribute : int, minStatsPerTroop: int, loyaltyToDistribute : int, minLoyaltyPerTroop : int):
	if statsToDistribute < minStatsPerTroop * amount:
		print("Can't meet min stats per troop with requested variables.")
	
	var maxStatsPerTroop = MAX_STAT_VALUE * STAT_COUNT
	if statsToDistribute > maxStatsPerTroop * amount:
		print("Too many stats to distribute. Aborting spawn to prevent loop.")
		return
	
	if loyaltyToDistribute < minLoyaltyPerTroop * amount:
		print("Can't meet min loyalty per troop with requested variables.")
	
	if (loyaltyToDistribute > MAX_LOYALTY_PER_TROOP * amount):
		print("Too much loyalty to distribute. Aborting spawn to prevent loop.")
		return
	
	var statsPerTroop : Array[int] = []
	var loyaltyPerTroop : Array[int] = []
	
	for i in range(amount):
		var troop = troopScene.instantiate()
		allTroops.append(troop)
		statsPerTroop.append(minStatsPerTroop)
		loyaltyPerTroop.append(minLoyaltyPerTroop)
		
		add_child(troop)
		troop.movement.position.x = i
		troop.movement.position.y = 1
	
	for i in range(statsToDistribute - (minStatsPerTroop * amount)):
		var randomIndex = randi() % amount
		while (statsPerTroop[randomIndex] >= maxStatsPerTroop):
			randomIndex = randi() % amount
		statsPerTroop[randomIndex] += 1
	
	for i in range(loyaltyToDistribute - (minLoyaltyPerTroop * amount)):
		var randomIndex = randi() % amount
		while (loyaltyPerTroop[randomIndex] >= MAX_LOYALTY_PER_TROOP):
			randomIndex = randi() % amount
		loyaltyPerTroop[randomIndex] += 1
	
	for i in range(amount):
		assign_stats_and_loyalty(allTroops[i], statsPerTroop[i], loyaltyPerTroop[i])

func spawn_generals() -> void:
	
	for i in range(3):
		var general = generalScene.instantiate()
		allGenerals.append(general)	
		add_child(general)
		general.movement.position = Vector3(i * 3, 1, 5)
	
	assign_stats_and_loyalty(allGenerals[0], LOYAL_GENERAL_STATS, LOYAL_GENERAL_LOYALTY)
	assign_stats_and_loyalty(allGenerals[1], SKILLED_GENERAL_STATS, SKILLED_GENERAL_LOYALTY)
	assign_stats_and_loyalty(allGenerals[2], DISLOYAL_GENERAL_STATS, DISLOYAL_GENERAL_LOYALTY)

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
