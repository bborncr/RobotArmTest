extends FileDialog


# Called when the node enters the scene tree for the first time.
func _ready():
	set_current_dir("res://saved_poses")
	invalidate()
	print("set current directory")