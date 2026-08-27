class_name MissionUI extends Control

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
	
