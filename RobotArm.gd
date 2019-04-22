extends Spatial

export(NodePath) var ik_path
var ik
export(NodePath) var ray_vertical_path
var ray_y
export(NodePath) var marker_path
export(NodePath) var ray_horizontal_path
var ray_z
export(NodePath) var marker2_path
export(NodePath) var camera_node

onready var marker = get_node(marker_path)
onready var marker2 = get_node(marker2_path)
onready var skeleton = get_node("Armature")
onready var camera = get_node(camera_node)
onready var base_gizmo = get_node("Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2/003-Arm2/BaseGizmo")
onready var x_label = get_node("HUD/CoordPanel/XTitle/XValue")
onready var y_label = get_node("HUD/CoordPanel/YTitle/YValue")
onready var z_label = get_node("HUD/CoordPanel/ZTitle/ZValue")
onready var easingx = get_node("EasingX")
onready var easingy = get_node("EasingY")
onready var easingz = get_node("EasingZ")

var is_marker1_under_mouse = false
var is_marker1_dragged = false
var is_camera_dragged = false
var is_y_gizmo_under_mouse = false
var is_y_gizmo_dragged = false
var is_x_gizmo_under_mouse = false
var is_x_gizmo_dragged = false
var is_ik_enabled = true

var x_target = 100
var y_target = 100
var z = 90

var _poses = {
	"speed": 1.5,
	"pause": .5,
	"loop": true,
	"pose": [
	{"x": 100,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90}
	]
}

func _ready():
	ik = get_node(ik_path)
	ray_y = get_node(ray_vertical_path)
	marker.show()
	ray_z = get_node(ray_horizontal_path)
	marker2.hide()
	set_process(true)
	
func _process(delta):
	if ray_y.is_enabled() and ray_y.is_colliding():
		var collision_point = ray_y.get_collision_point()
		marker.set_translation(collision_point)
	
	if ray_z.is_enabled() and ray_z.is_colliding():
		var vertical_pos = ray_z.get_collision_point().y
		var marker_pos = Vector3()
		marker_pos.x = 0
		marker_pos.y = vertical_pos
		marker_pos.z = 0
		marker2.set_translation(marker_pos)
		
	if is_ik_enabled:
		ik.calcIK(x_target, y_target, z, 90, 90, 90)
		x_label.text = str(int(x_target))
		y_label.text = str(int(y_target))
		z_label.text = str(int(z))
	
func _unhandled_input(event):
	
	# Drag Z Gizmo
	if event is InputEventMouseButton and event.is_pressed() and is_marker1_under_mouse:
		is_marker1_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("Marker1 being dragged")
	if event is InputEventMouseButton and !event.is_pressed() and is_marker1_dragged:
		is_marker1_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
		print("Marker1 released")
	if event is InputEventMouseMotion and is_marker1_dragged:
#		print(event.relative)
		skeleton.rotate_object_local(Vector3(0,1,0), event.relative.x * PI/360)
		z = z + event.relative.x
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
		if event.get_button_index() == 4:
			camera.translate(Vector3(0,0,-1))
		if event.get_button_index() == 5:
			camera.translate(Vector3(0,0,1))
	
	# Drag Y Gizmo
	if event is InputEventMouseButton and event.is_pressed() and is_y_gizmo_under_mouse:
		is_y_gizmo_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("y gizmo dragged")
	if event is InputEventMouseButton and !event.is_pressed() and is_y_gizmo_dragged:
		is_y_gizmo_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
		print("y gizmo released")
	if event is InputEventMouseMotion and is_y_gizmo_dragged:
		y_target = y_target - event.relative.y
		y_label.text = str(y_target)
	
	# Drag X Gizmo
	if event is InputEventMouseButton and event.is_pressed() and is_x_gizmo_under_mouse:
		is_x_gizmo_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("x gizmo dragged")
	if event is InputEventMouseButton and !event.is_pressed() and is_x_gizmo_dragged:
		is_x_gizmo_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
		print("x gizmo released")
	if event is InputEventMouseMotion and is_x_gizmo_dragged:
		x_target = x_target + event.relative.x
		x_label.text = str(x_target)
	
func _on_BaseGizmo_mouse_entered():
	is_marker1_under_mouse = true
	
func _on_BaseGizmo_mouse_exited():
	is_marker1_under_mouse = false
	
func _on_VerticalGuide_mouse_entered():
	pass
	
func _on_ArmIK_servo_moved(base, shoulder, elbow, wrist, gripper):
	$"Armature/002-Shoulder2".set_rotation_degrees(Vector3(shoulder-90, 0, 0))
	$"Armature/002-Shoulder2/Spatial".set_rotation_degrees(Vector3(elbow-90, 0, 0)) 
	$"Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2".set_rotation_degrees(Vector3(90-wrist, 0, 0))

func _on_HUD_servo_manually_moved(base, shoulder, elbow, wrist, gripper):
	$"Armature/002-Shoulder2".set_rotation_degrees(Vector3(shoulder-90, 0, 0))
	$"Armature/002-Shoulder2/Spatial".set_rotation_degrees(Vector3(elbow-90, 0, 0)) 
	$"Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2".set_rotation_degrees(Vector3(90-wrist, 0, 0))
	skeleton.set_rotation_degrees(Vector3(0,base-90,0))

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


func _on_Button_pressed():
	var new_pose = {"x": 100,"y": 100,"z": 90,"g": 90,"wa": 90,"wr": 90}
	new_pose.x = x_target
	new_pose.y = y_target
	new_pose.z = z
	_poses.pose.append(new_pose)
	print("Added new pose")
	print("Num poses:",_poses.pose.size())


func _on_Button2_pressed():
	for pose in _poses.pose:
		if pose.has("x"):
			easingx.interpolate_property(self, 'x_target', x_target, pose.x, _poses.speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		if pose.has("y"):
			easingy.interpolate_property(self, 'y_target', y_target, pose.y, _poses.speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		if pose.has("z"):
			easingz.interpolate_property(self, 'z', z, pose.z, _poses.speed, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
		easingx.start()
		easingy.start()
		easingz.start()
		print("x:",x_target)
		print("y:",y_target)
		print("z:",z)
		yield(get_tree().create_timer(_poses.speed + _poses.pause), "timeout")

func _on_Button4_pressed():
	$HUD/FileDialog.set_mode(FileDialog.MODE_SAVE_FILE)
	$HUD/FileDialog.popup()
	
func _on_Button3_pressed():
	$HUD/FileDialog.set_mode(FileDialog.MODE_OPEN_FILE)
	$HUD/FileDialog.popup()

func _on_FileDialog_file_selected(path):
	$HUD/FileDialog.popup()
	if $HUD/FileDialog.get_mode() == FileDialog.MODE_OPEN_FILE:
		print("Loading...")
		print(path)
		_poses = FileAccess.load(path)
		$HUD/FileDialog.popup()
	elif $HUD/FileDialog.get_mode() == FileDialog.MODE_SAVE_FILE:
		print("Save")
		FileAccess.save(_poses, path)
		$HUD/FileDialog.popup()
		
