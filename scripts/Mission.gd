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

@export var mission_name:String = "The Most Dangerous Mission"
@export var mission_description:String = "LOSE YOUR MIND"

@export var skillCheck : int = 20
@export var rewardType : MissionRewardType
@export var penaltyType : MissionPenaltyType
@export var skillRequired : CharacterStats.SkillType
#@export var statWeights : Dictionary[MissionSkillType, int] = {0:0, 1:0, 2:0}

@onready var dropoff:MissionDropoff = $DropoffRegion as MissionDropoff

@onready var notif_packed = preload("res://scenes/fading_notif.tscn") as PackedScene

func difficulty_percent() -> float:
	return inverse_lerp(MIN_SKILL_CHECK, MAX_SKILL_CHECK, skillCheck)

func perform_mission(general : General, party : Array[Troop]):
	var notif_text:String = ""
	var success:bool = generateOutcome(general, party)
	if success:
		notif_text = "Victory- " + mission_name + ": "
		if rewardType == MissionRewardType.SUPPLIES:
			var supplies_rewarded = lerp(MIN_SUPPLIES, MAX_SUPPLIES, difficulty_percent())
			supplies_rewarded = ceili(supplies_rewarded)
			Game.instance._on_supplies_found.emit(supplies_rewarded)
			notif_text += "+" + str(supplies_rewarded) + " Supplies"
		if rewardType == MissionRewardType.LOYALTY:
			var loyalty_reward = floori(lerp(MIN_LOYALTY, MAX_LOYALTY, difficulty_percent()))
			for troop in Game.instance.allTroops:
				troop.stats.gain_loyalty(loyalty_reward)
			notif_text += "+Loyalty"
		if rewardType == MissionRewardType.VICTORY_POINTS:
			Game.instance._on_favor_earned.emit(1)
			notif_text += "+Favor"
	else:
		notif_text = "Defeat- " + mission_name + ": "
		if penaltyType == MissionPenaltyType.HEALTH:
			notif_text += "-Health"
		if penaltyType == MissionPenaltyType.SANITY:
			notif_text += "-Sanity"
		harm_troops(party)
	spreadLoyalty(general, party)
	
	var notif = notif_packed.instantiate() as FadingNotification
	add_child(notif)
	notif.setup(notif_text, 2.0)
	

func generateOutcome(general : General, party : Array[Troop]) -> bool:
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
	var totalLoyalty = (general.stats.loyalty * GENERAL_LOYALTY_WEIGHT)
	for troop in party:
		totalLoyalty += troop.stats.loyalty
	
	var averageLoyalty : float = totalLoyalty / (party.size() + 1)
	
	for troop in party:
		var impact = (averageLoyalty - troop.stats.loyalty) / 2
		if (impact > 0.5):
			troop.stats.gain_loyalty(round(impact))
		if (impact < 0.5):
			troop.stats.lose_loyalty(round(impact))	

func calculateLoyaltyMult(character : Character) -> float:
	return MIN_LOYALTY_MULT + ((MAX_LOYALTY_MULT - MIN_LOYALTY_MULT) * (character.stats.loyalty as float / CharacterStats.MAX_LOYALTY))

func harm_troops(troops:Array[Troop]) -> void:
	var penalty_chance = lerp(MIN_PENALTY_CHANCE, MAX_PENALTY_CHANCE, difficulty_percent())
	for troop in troops:
		if randf() < penalty_chance:
			harm_troop(troop)

func harm_troop(troop:Troop):
	print("harmed troop")
	if penaltyType == MissionPenaltyType.HEALTH:
		troop.stats.take_damage(1)
	if penaltyType == MissionPenaltyType.SANITY:
		troop.stats.lose_sanity(1)
