class_name Game extends Node

const AMOUNT_OF_TROOPS = 9
const STATS_TO_DISTRIBUTE = 100
const MIN_STATS_PER_TROOP = 6

var troopScene = preload("res://scenes/troop.tscn")
var allTroops : Array[Troop] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_troops(AMOUNT_OF_TROOPS, STATS_TO_DISTRIBUTE, MIN_STATS_PER_TROOP)

func spawn_troops(amount : int, statsToDistribute : int, minStatsPerTroop: int):
	if statsToDistribute < minStatsPerTroop * amount:
		print("Can't meet min stats per troop with requested variables.")
	
	var statsPerTroop : Array[int] = []

	for i in range(amount):
		var troop = troopScene.instantiate()
		allTroops.append(troop)
		statsPerTroop.append(minStatsPerTroop)
		
		add_child(troop)
		troop.movement.position.x = i
	
	for i in range(statsToDistribute - (minStatsPerTroop * amount)):
		var randomIndex = randi() % amount
		statsPerTroop[randomIndex] += 1
		
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
		allTroops[i].stats.set_stats(might, guile, favor);
