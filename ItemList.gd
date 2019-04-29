extends ItemList

onready var context_menu = $ContextMenu

#onready var data = get_node("/root/Data")
#
#onready var dict = data.poses

var from = null
var to = null
var selected = null
var pose_icon = load("res://art/sliders.svg")

enum Action {MOVE, DELETE, NONE = -1}

var current_action = Action.NONE

func _ready():
	load_data()
		
func _on_ItemList_item_activated(index):
	if current_action == Action.MOVE:
		to = index
		move_item(from, to)
		current_action = Action.NONE
		update_poses()

func _on_ItemList_item_rmb_selected(index, at_position):
	selected = index
#	print("selected: ", selected)
	var mouse_position = get_viewport().get_mouse_position()
	context_menu.rect_position = mouse_position
	context_menu.show()

func _on_ContextMenu_index_pressed(index):
	if index == Action.MOVE:
		current_action = Action.MOVE
		from = selected
	elif index == Action.DELETE and selected !=null:
		current_action = Action.DELETE
		remove_item(selected)
		selected = null
		current_action = Action.NONE
		update_poses()

func _on_ContextMenu_focus_exited():
	context_menu.hide()

func update_poses():
	Data.poses.pose.clear()
	for i in get_item_count():
		Data.poses.pose.append(get_item_metadata(i))
	for i in Data.poses.pose.size():
		print(Data.poses.pose[i])

func load_data():
#	print("Clearing")
	clear()
	for i in Data.poses.pose.size():
		add_item("Pose: " + str(i), pose_icon)
		set_item_metadata(i, Data.poses.pose[i])
#		print("adding items")