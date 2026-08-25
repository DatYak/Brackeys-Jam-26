class_name Mission extends Node3D

const GENERAL_WEIGHT = 4.0
const MIN_RANDOM_MULT = 0.8
const MAX_RANDOM_MULT = 1.2
const MIN_LOYALTY_MULT = 0.1
const MAX_LOYALTY_MULT = 1.5
const IDEAL_TROOP_COUNT = 2.75


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

func generateOutcome(general : General, party : Array[Troop]):
	var rng = RandomNumberGenerator.new()
	var randomMult = randf_range(MIN_RANDOM_MULT, MAX_RANDOM_MULT)
	
	var generalFactor = general.stats.get_skill(skillRequired) * GENERAL_WEIGHT * calculateLoyaltyMult(general)
	
	var troopSizeFactor = 1.0 / (1.0 + abs(party.size() - IDEAL_TROOP_COUNT))
	
	var troopSummation = 0.0
	for troop in party:		
		troopSummation += troop.stats.getStat(skillRequired) * calculateLoyaltyMult(troop)
	
	var outcome = randomMult * (generalFactor + (troopSizeFactor * troopSummation))
	print("Outcome value: " + outcome + " Skill Check: " + skillCheck)

func calculateLoyaltyMult(character : Character) -> float:
	return MIN_LOYALTY_MULT + ((MAX_LOYALTY_MULT - MIN_LOYALTY_MULT) * character.stats.loyalty)
