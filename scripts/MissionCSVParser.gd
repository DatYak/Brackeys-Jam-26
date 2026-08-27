class_name MissionCSVParser extends RefCounted
var missionsByDifficulty = [[]]
var path = "res://text/Odyssey Jam - Missions - Sheet1.csv"

func get_random_mission_by_difficulty(difficulty : int) -> MissionData:
	
	var mission = missionsByDifficulty[difficulty].pick_random()
	if (mission == null):
		loadData()
		return get_random_mission_by_difficulty(difficulty)
	
	missionsByDifficulty[difficulty].erase(mission)
	return mission

func loadData():
	var rows = TextFileLoader.load_text_file_and_split(path)
	rows.remove_at(0)
	rows.remove_at(0)
	rows.remove_at(0)
	
	missionsByDifficulty = [[],[],[]]
	for row in rows:
		var cells = row.split(",")		
		var type = cells[0]
		var skill = parseSkill(cells[1])
		var reward = parseReward(cells[2])
		var penalty = parsePenalty(cells[3])
		
		for difficulty in range(3):
			var missionData = MissionData.new()
			missionData.mission_type = type
			missionData.skill_used = skill
			missionData.success_reward = reward
			missionData.failure_penalty = penalty
			missionData.difficulty = difficulty + 1
			missionData.name = cells[4+(difficulty*2)]
			missionData.description = cells[5+(difficulty*2)]
			
			if missionData.name == "":
				continue
			missionsByDifficulty[difficulty].append(missionData)

func parseSkill(str : String) -> CharacterStats.SkillType:
	match str.strip_edges():
		"Might":
			return CharacterStats.SkillType.MIGHT
		"Guile":
			return CharacterStats.SkillType.GUILE
		"Nerve":
			return CharacterStats.SkillType.NERVE
		_:
			print("Failed to parse " + str + " as skill")
			return CharacterStats.SkillType.MIGHT

func parseReward(str : String) -> Mission.MissionRewardType:
	match str.strip_edges():
		"Supplies":
			return Mission.MissionRewardType.SUPPLIES
		"Loyalty":
			return Mission.MissionRewardType.LOYALTY
		"Favor":
			return Mission.MissionRewardType.VICTORY_POINTS
		_:
			print("Failed to parse " + str + " as mission reward type")
			return Mission.MissionRewardType.SUPPLIES

func parsePenalty(str : String) -> Mission.MissionPenaltyType:
	match str.strip_edges():
		"Health":
			return Mission.MissionPenaltyType.HEALTH
		"Sanity":
			return Mission.MissionPenaltyType.SANITY
		_:
			print("Failed to parse " + str + " as mission penalty type")
			return Mission.MissionPenaltyType.HEALTH
