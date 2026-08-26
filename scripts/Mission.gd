class_name Mission extends Node3D

const GENERAL_OUTCOME_WEIGHT = 4.0
const MIN_RANDOM_MULT = 0.8
const MAX_RANDOM_MULT = 1.2
const MIN_LOYALTY_MULT = 0.1
const MAX_LOYALTY_MULT = 1.5
const IDEAL_TROOP_COUNT = 2.75

const GENERAL_LOYALTY_WEIGHT = 5.0

const MAX_SKILL_CHECK = 20
const MIN_SKILL_CHECK = 1

const MAX_SUPPLIES = 100
const MIN_SUPPLIES = 20

const MAX_LOYALTY = 3
const MIN_LOYALTY = 1

const MIN_PENALTY_CHANCE = 0.2
const MAX_PENALTY_CHANCE = 0.8

enum MissionRewardType {
	SUPPLIES,
	LOYALTY,
	VICTORY_POINTS,
}

enum MissionPenaltyType {
	HEALTH,
	SANITY
}

@export var skillCheck : int = 20
@export var rewardType : MissionRewardType
@export var penaltyType : MissionPenaltyType
@export var skillRequired : CharacterStats.SkillType
#@export var statWeights : Dictionary[MissionSkillType, int] = {0:0, 1:0, 2:0}

@onready var dropoff:MissionDropoff = $DropoffRegion as MissionDropoff

func difficulty_percent() -> float:
	return inverse_lerp(MIN_SKILL_CHECK, MAX_SKILL_CHECK, skillCheck)

func perform_mission(game:Game, general : General, party : Array[Troop]):
	var success:bool = generateOutcome(general, party)
	if success:
		if rewardType == MissionRewardType.SUPPLIES:
			var supplies_rewarded = lerp(MIN_SUPPLIES, MAX_SUPPLIES, difficulty_percent())
			supplies_rewarded = ceili(supplies_rewarded)
			game._on_supplies_found.emit(supplies_rewarded)
		if rewardType == MissionRewardType.LOYALTY:
			var loyalty_reward = floori(lerp(MIN_LOYALTY, MAX_LOYALTY, difficulty_percent()))
			for troop in game.allTroops:
				troop.stats.gain_loyalty(loyalty_reward)
	else:
		harm_troops(party)
	spreadLoyalty(general, party)
	

func generateOutcome(general : General, party : Array[Troop]) -> bool:
	var rng = RandomNumberGenerator.new()
	var randomMult = randf_range(MIN_RANDOM_MULT, MAX_RANDOM_MULT)
	
	var generalFactor = general.stats.get_skill(skillRequired) * GENERAL_OUTCOME_WEIGHT * calculateLoyaltyMult(general)
	
	var troopSizeFactor = 1.0 / (1.0 + abs(party.size() - IDEAL_TROOP_COUNT))
	
	var troopSummation = 0.0
	for troop in party:		
		troopSummation += troop.stats.get_skill(skillRequired) * calculateLoyaltyMult(troop)
	
	var outcome = randomMult * (generalFactor + (troopSizeFactor * troopSummation))
	print("Outcome value: " + str(outcome) + " Skill Check: " + str(skillCheck))
	return outcome > skillCheck


func spreadLoyalty(general : General, party : Array[Troop]):
	var maxLoyalty = CharacterStats.MAX_LOYALTY
	
	var totalLoyalty = (general.stats.loyalty * GENERAL_LOYALTY_WEIGHT)
	for troop in party:
		totalLoyalty += troop.stats.loyalty
	
	var averageLoyalty : float = totalLoyalty / (party.size() + 1)
	
	for troop in party:
		var impact = (averageLoyalty - troop.stats.loyalty) / 2
		if (impact >= 0.5):
			troop.stats.gain_loyalty(round(impact))
		if (impact <= 0.5):
			troop.stats.lose_loyalty(round(impact))	

func calculateLoyaltyMult(character : Character) -> float:
	return MIN_LOYALTY_MULT + ((MAX_LOYALTY_MULT - MIN_LOYALTY_MULT) * (character.stats.loyalty / CharacterStats.MAX_LOYALTY))

func harm_troops(troops:Array[Troop]) -> void:
	var penalty_chance = lerp(MIN_PENALTY_CHANCE, MAX_PENALTY_CHANCE, difficulty_percent())
	for troop in troops:
		if randf() < penalty_chance:
			harm_troop(troop)

func harm_troop(troop:Troop):
	print("HARMED TROOP")
	if penaltyType == MissionPenaltyType.HEALTH:
		troop.stats.take_damage(1)
	if penaltyType == MissionPenaltyType.SANITY:
		troop.stats.lose_sanity(1)
