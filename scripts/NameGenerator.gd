class_name NameGenerator extends RefCounted

const CHANCE_OF_EPITHET = 0.8

const names_file_path = "res://text/first-names.txt"
const epithets_file_path = "res://text/epithets.txt"

static var name_list : PackedStringArray
static var epithet_list : PackedStringArray

static func generate_name() -> String:
	if name_list == null or name_list.is_empty(): # load list from file if not loaded yet
		name_list = TextFileLoader.load_text_file_and_split(names_file_path)
	
	if epithet_list == null or epithet_list.is_empty():
		epithet_list = TextFileLoader.load_text_file_and_split(epithets_file_path)
	
	var random_name = randi() % name_list.size()
	var name = name_list[random_name]
	name_list.remove_at(random_name)
	
	if randf_range(0, 1) < CHANCE_OF_EPITHET:
		var random_epithet = randi() % epithet_list.size()
		name += " the " + epithet_list[random_epithet]
		epithet_list.remove_at(random_epithet)
	
	name = name.replace("\r", "")
	return name
