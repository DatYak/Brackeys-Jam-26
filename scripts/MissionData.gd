class_name MissionData extends RefCounted

var mission_type : String
var skill_used : CharacterStats.SkillType
var success_reward : Mission.MissionRewardType
var failure_penalty : Mission.MissionPenaltyType

var name : String
var description : String
var difficulty : int

var skill_check : int
