extends Node

const FILE_PATH = "res://saved_poses/default.json"

## example pose format
#var _poses = {
#	"loop": true,
#	"speed": 100,
#	"pose": [
#	{"x": 100,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90},
#	{"delay": 1000},
#	{"x": 120,"y": 90,"z": 90,"g": 90,"wa": 90,"wr": 90}
#	]
#}

# Saves dictionay to json format file
func save(content, file_path = FILE_PATH):
	var file = File.new()
	file.open(file_path, File.WRITE)
	file.store_string(to_json(content))
	file.close()
	
func load(file_path = FILE_PATH):
	var file = File.new()
	file.open(file_path, File.READ)
	var content = file.get_as_text()
	var parsed = parse_json(content)
	file.close()
	return parsed
