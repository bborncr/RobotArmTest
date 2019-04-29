extends Node

var poses = {
	"speed": 1.5,
	"pause": .5,
	"loop": true,
	"pose": [
	{"x": 100,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90},
	{"x": 101,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90},
	{"x": 102,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90},
	{"x": 103,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90},
	{"x": 104,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90}
	]
}

# Called when the node enters the scene tree for the first time.
func _ready():
	poses = FileAccess.load()