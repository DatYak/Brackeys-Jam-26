class_name MissionUI extends Control

const EASY_LABEL = "(E) Task of "
const MID_LABEL = "(M) Test of "
const HARD_LABEL = "(H) Trial of "

@onready var mission:Mission = $".."

@onready var name_lbl : Label = $Background/Name/Label
@onready var difficulty_lbl : Label = $Background/Type/Label
@onready var desc_lbl : Label = $Background/Desc
@onready var recieve_lbl : Label = $Background/Recieve
@onready var lose_lbl : Label = $Background/Lose

func _ready() -> void:
	visible = false

func display():
	name_lbl.text = mission.mission_name
	desc_lbl.text = mission.mission_description 
	if mission.rewardType == Mission.MissionRewardType.SUPPLIES:
		recieve_lbl.text = "+Supplies"
		recieve_lbl.label_settings.font_color = Color("ccbb44")
	if mission.rewardType == Mission.MissionRewardType.LOYALTY:
		recieve_lbl.text = "+Loyalty"
		recieve_lbl.label_settings.font_color = Color("FFFFFF")
	if mission.rewardType == Mission.MissionRewardType.VICTORY_POINTS:
		recieve_lbl.text = "+Favor"
		recieve_lbl.label_settings.font_color = Color("2e2585")
	if mission.penaltyType == Mission.MissionPenaltyType.HEALTH:
		lose_lbl.text = "-Health"
		lose_lbl.label_settings.font_color = Color("ee6677")
	if mission.penaltyType == Mission.MissionPenaltyType.SANITY:
		lose_lbl.text = "-Sanity"
		lose_lbl.label_settings.font_color = Color("4477aa")
	
	var diff_label:String = ""
	
	var difficulty:float = mission.difficulty_percent()
	if difficulty < 0.33:
		diff_label = EASY_LABEL
	else: if difficulty < 0.66:
		diff_label = MID_LABEL
	else:
		diff_label = HARD_LABEL
	
	if mission.skillRequired == CharacterStats.SkillType.MIGHT:
		difficulty_lbl.label_settings.font_color = Color("#d95f02")
		diff_label += "Might"
	
	if mission.skillRequired == CharacterStats.SkillType.GUILE:
		difficulty_lbl.label_settings.font_color = Color("#4daf4a")
		diff_label += "Guille"
		
	if mission.skillRequired == CharacterStats.SkillType.NERVE:
		difficulty_lbl.label_settings.font_color = Color("#3a8eba")
		diff_label += "Nerve"
		
	difficulty_lbl.text = diff_label
