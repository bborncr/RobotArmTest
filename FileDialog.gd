extends FileDialog

func _draw(): # certain methods do not work directly called to $FileDialog
	set_current_dir("res://saved_poses")
	deselect_items()