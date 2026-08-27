class_name TextFileLoader extends RefCounted

static func load_text_file(path : String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	var text = file.get_as_text()
	file.close()
	return text

static func load_text_file_and_split(path : String, delimiter : String = "\n") -> PackedStringArray:
	var text = load_text_file(path)
	return text.split(delimiter, false)
