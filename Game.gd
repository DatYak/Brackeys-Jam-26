class_name Game extends Node

const AMOUNT_OF_TROOPS = 9
const STATS_TO_DISTRIBUTE = 100
const MIN_STATS_PER_TROOP = 6

const MIN_STAT_VALUE = 1
const MAX_STAT_VALUE = 5
const STAT_COUNT = 3

const LOYALTY_TO_DISTRIBUTE = 65
const MIN_LOYALTY_PER_TROOP = 3
const MAX_LOYALTY_PER_TROOP = 10

const STATS_FOR_LOYAL_GENERAL = 0
const STATS_FOR_SKILLED_GENERAL = 0
const STATS_FOR_DISLOYAL_GENERAL = 0

var troopScene = preload("res://scenes/troop.tscn")
var allTroops : Array[Troop] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_troops(AMOUNT_OF_TROOPS, STATS_TO_DISTRIBUTE, MIN_STATS_PER_TROOP, LOYALTY_TO_DISTRIBUTE, MIN_LOYALTY_PER_TROOP)

func spawn_troops(amount : int, statsToDistribute : int, minStatsPerTroop: int, loyaltyToDistribute : int, minLoyaltyPerTroop : int):
	if statsToDistribute < minStatsPerTroop * amount:
		print("Can't meet min stats per troop with requested variables.")
	
	if loyaltyToDistribute < minLoyaltyPerTroop * amount:
		print("Can't meet min loyalty per troop with requested variables.")
	
	var statsPerTroop : Array[int] = []
	var loyaltyPerTroop : Array[int] = []

	for i in range(amount):
		var troop = troopScene.instantiate()
		allTroops.append(troop)
		statsPerTroop.append(minStatsPerTroop)
		loyaltyPerTroop.append(minLoyaltyPerTroop)
		
		add_child(troop)
		troop.movement.position.x = i
	
	for i in range(statsToDistribute - (minStatsPerTroop * amount)):
		var randomIndex = randi() % amount
		statsPerTroop[randomIndex] += 1
	
	for i in range(loyaltyToDistribute - (minLoyaltyPerTroop * amount)):
		var randomIndex = randi() % amount
		loyaltyPerTroop[randomIndex] += 1
	
	for i in range(amount):
		var might = 0
		var guile = 0
		var favor = 0
		for j in range(statsPerTroop[i]):
			var stat = randi() % 3
			match stat:
				0:
					might += 1
				1:
					guile += 1
				2:
					favor += 1
		allTroops[i].stats.set_stats(might, guile, favor, loyaltyPerTroop[i]);
