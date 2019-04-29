extends Spatial

export(NodePath) var ik_path
var ik
export(NodePath) var camera_node

onready var skeleton = get_node("Armature")
onready var camera = get_node(camera_node)
onready var base_gizmo = get_node("Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2/003-Arm2/BaseGizmo")
onready var x_label = get_node("HUD/CoordPanel/XTitle/XValue")
onready var y_label = get_node("HUD/CoordPanel/YTitle/YValue")
onready var z_label = get_node("HUD/CoordPanel/ZTitle/ZValue")
onready var easingx = get_node("EasingX")
onready var easingy = get_node("EasingY")
onready var easingz = get_node("EasingZ")
onready var pose_editor = get_node("PoseEditor/Panel/MarginContainer/ItemList")

var is_z_gizmo_under_mouse = false
var is_z_gizmo_dragged = false
var is_camera_dragged = false
var is_y_gizmo_under_mouse = false
var is_y_gizmo_dragged = false
var is_x_gizmo_under_mouse = false
var is_x_gizmo_dragged = false
var is_ik_enabled = true

var x_target = 100
var y_target = 100
var z = 90

var timer = false
var playing = false
var pose_selected = 0

var mandatory_keys = ["x", "y", "z", "g", "wa", "wr"]

func _ready():
	ik = get_node(ik_path)
#	marker.hide()
	set_process(true)
	
func _process(delta):
		
	if is_ik_enabled and timer:
#		timer = false # delay timer is disabled
		ik.calcIK(x_target, y_target, z, 90, 90, 90)
		x_label.text = str(int(x_target))
		y_label.text = str(int(y_target))
		z_label.text = str(int(z))
	
func _unhandled_input(event):
	
	# Drag Z Gizmo
	if event is InputEventMouseButton and event.is_pressed() and is_z_gizmo_under_mouse:
		is_z_gizmo_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#		print("z gizmo being dragged")
	if event is InputEventMouseButton and !event.is_pressed() and is_z_gizmo_dragged:
		is_z_gizmo_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
#		print("z gizmo released")
	if event is InputEventMouseMotion and is_z_gizmo_dragged:
#		print(event.relative)
		skeleton.rotate_object_local(Vector3(0,1,0), -event.relative.x * PI/360)
		z = z + -event.relative.x
		z_label.text = str(z)
	# Hold down middle mouse to orbit camera around robot arm
	if event is InputEventMouseButton and event.get_button_index() == 3 and event.is_pressed():
		is_camera_dragged = true
	if event is InputEventMouseButton and event.get_button_index() == 3 and !event.is_pressed():
		is_camera_dragged = false
	if event is InputEventMouseMotion and is_camera_dragged:
		$FocusPoint/Gimbal.rotate_object_local(Vector3(0,0,1), event.relative.y * PI/360)
		$FocusPoint.rotate_object_local(Vector3(0,-1,0), event.relative.x * PI/360)
		
	# Scroll mouse to change camera distance from robot arm
	if event is InputEventMouseButton:
		if event.get_button_index() == BUTTON_WHEEL_UP:
			camera.translate(Vector3(0,0,-1))
		if event.get_button_index() == BUTTON_WHEEL_DOWN:
			camera.translate(Vector3(0,0,1))
	
	# Drag Y Gizmo
	if event is InputEventMouseButton and event.is_pressed() and is_y_gizmo_under_mouse:
		is_y_gizmo_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#		print("y gizmo dragged")
	if event is InputEventMouseButton and !event.is_pressed() and is_y_gizmo_dragged:
		is_y_gizmo_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
#		print("y gizmo released")
	if event is InputEventMouseMotion and is_y_gizmo_dragged:
		y_target = y_target - event.relative.y
		y_label.text = str(y_target)
	
	# Drag X Gizmo
	if event is InputEventMouseButton and event.is_pressed() and is_x_gizmo_under_mouse:
		is_x_gizmo_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
#		print("x gizmo dragged")
	if event is InputEventMouseButton and !event.is_pressed() and is_x_gizmo_dragged:
		is_x_gizmo_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
#		print("x gizmo released")
	if event is InputEventMouseMotion and is_x_gizmo_dragged:
		x_target = x_target + event.relative.x
		x_label.text = str(x_target)
	
func _on_BaseGizmo_mouse_entered():
	is_z_gizmo_under_mouse = true
	
func _on_BaseGizmo_mouse_exited():
	is_z_gizmo_under_mouse = false
	
func _on_ArmIK_servo_moved(base, shoulder, elbow, wrist, gripper):
	if is_ik_enabled:
		skeleton.set_rotation_degrees(Vector3(0,90-base,0))
		$"Armature/002-Shoulder2".set_rotation_degrees(Vector3(shoulder-90, 0, 0))
		$"Armature/002-Shoulder2/Spatial".set_rotation_degrees(Vector3(elbow-90, 0, 0)) 
		$"Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2".set_rotation_degrees(Vector3(90-wrist, 0, 0))

func _on_HUD_servo_manually_moved(base, shoulder, elbow, wrist, gripper):
	if !is_ik_enabled:
		$"Armature/002-Shoulder2".set_rotation_degrees(Vector3(shoulder-90, 0, 0))
		$"Armature/002-Shoulder2/Spatial".set_rotation_degrees(Vector3(elbow-90, 0, 0)) 
		$"Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2".set_rotation_degrees(Vector3(90-wrist, 0, 0))
		skeleton.set_rotation_degrees(Vector3(0,base-90,0))
		var format_string = "%d,%d,%d,%d,%d"
#		print(format_string % [base, shoulder, elbow, wrist, gripper])

func _on_HUD_is_ik_enabled(value):
	is_ik_enabled = value

func _on_YGizmo_mouse_entered():
	is_y_gizmo_under_mouse = true
#	print("YGizmo Enter")

func _on_YGizmo_mouse_exited():
	is_y_gizmo_under_mouse = false
#	print("YGizmo Exit")


func _on_XGizmo_mouse_entered():
	is_x_gizmo_under_mouse = true
#	print("XGizmo Enter")


func _on_XGizmo_mouse_exited():
	is_x_gizmo_under_mouse = false
#	print("XGizmo Exit")

# ADD pose
func _on_Button_pressed():
	var new_pose = {"x": 100,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90}
	new_pose.x = x_target
	new_pose.y = y_target
	new_pose.z = z
	if pose_selected == Data.poses.pose.size():
		Data.poses.pose.append(new_pose)
	else:
		Data.poses.pose.insert(pose_selected + 1, new_pose)
	pose_selected = pose_selected + 1
	pose_editor.load_data()
	pose_editor.select(pose_selected)
#	print("Added new pose")
#	print("Num poses:",poses.pose.size())

# PLAY
func _on_Button2_pressed():
	playing = true
	for i in Data.poses.pose.size():
		if Data.poses.pose[i].has_all(mandatory_keys):
			easingx.interpolate_property(self, 'x_target', x_target, Data.poses.pose[i].x, Data.poses.speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			easingy.interpolate_property(self, 'y_target', y_target, Data.poses.pose[i].y, Data.poses.speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
			easingz.interpolate_property(self, 'z', z, Data.poses.pose[i].z, Data.poses.speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		else:
			print("Error: pose does not have all mandatory keys")
		easingx.start()
		easingy.start()
		easingz.start()
		pose_editor.select(i)
#		print("x:",x_target)
#		print("y:",y_target)
#		print("z:",z)
		yield(get_tree().create_timer(Data.poses.speed + Data.poses.pause), "timeout")
		pose_editor.unselect(i)
	playing = false
	pose_selected = Data.poses.pose.size()-1
	pose_editor.select(pose_selected)

# SAVE button
func _on_Button4_pressed():
	$HUD/FileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	$HUD/FileDialog.show_modal(true)
	
# LOAD button
func _on_Button3_pressed():
	$HUD/FileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	$HUD/FileDialog.show_modal(true)

func _on_FileDialog_file_selected(path):
	if $HUD/FileDialog.get_mode() == FileDialog.MODE_OPEN_FILE:
		print("Loading...")
		print(path)
		Data.poses = FileAccess.load(path)
		pose_selected = Data.poses.pose.size()
#		print(Data.poses)
		pose_editor.load_data()
	elif $HUD/FileDialog.get_mode() == FileDialog.MODE_SAVE_FILE:
		print("Saving...")
		print(path)
		FileAccess.save(Data.poses, path)

func _on_Timer_timeout():
	timer = true

func _on_ItemList_item_selected(index):
	if !playing:
		x_target = Data.poses.pose[index].x
		y_target = Data.poses.pose[index].y
		z = Data.poses.pose[index].z
		pose_selected = index
