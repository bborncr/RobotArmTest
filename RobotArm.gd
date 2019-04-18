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

func _ready():
#	target = get_node(target_path)
	ik = get_node(ik_path)
#	ik.start() # used for the SkeletonIK node
	ray_y = get_node(ray_vertical_path)
	marker.show()
	ray_z = get_node(ray_horizontal_path)
	marker2.hide()
	
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed("ui_up"):
		y_target = y_target + 1
	if Input.is_action_pressed("ui_down"):
		y_target = y_target - 1
	if Input.is_action_pressed("ui_left"):
		x_target = x_target - 1
	if Input.is_action_pressed("ui_right"):
		x_target = x_target + 1
		
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
		ik.calcIK(x_target, y_target, 90, 90, 90, 90)
	
func _unhandled_input(event):
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
		print(event.relative)
		skeleton.rotate_object_local(Vector3(0,1,0), event.relative.x * PI/360)
	if event is InputEventMouseButton and event.get_button_index() == 3 and event.is_pressed():
		is_camera_dragged = true
	if event is InputEventMouseButton and event.get_button_index() == 3 and !event.is_pressed():
		is_camera_dragged = false
	if event is InputEventMouseMotion and is_camera_dragged:
		$FocusPoint/Gimbal.rotate_object_local(Vector3(0,0,1), event.relative.y * PI/360)
		$FocusPoint.rotate_object_local(Vector3(0,-1,0), event.relative.x * PI/360)
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
		
	if event is InputEventMouseButton and event.is_pressed() and is_x_gizmo_under_mouse:
		is_x_gizmo_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("x gizmo dragged")
		$HUD.send_message("x gizmo")
	if event is InputEventMouseButton and !event.is_pressed() and is_x_gizmo_dragged:
		is_x_gizmo_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = camera.unproject_position(base_gizmo.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
		print("x gizmo released")
	if event is InputEventMouseMotion and is_x_gizmo_dragged:
		x_target = x_target + event.relative.x
	
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
	print("YGizmo Enter")

func _on_YGizmo_mouse_exited():
	is_y_gizmo_under_mouse = false
	print("YGizmo Exit")


func _on_XGizmo_mouse_entered():
	is_x_gizmo_under_mouse = true
	print("XGizmo Enter")


func _on_XGizmo_mouse_exited():
	is_x_gizmo_under_mouse = false
	print("XGizmo Exit")
