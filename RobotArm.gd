extends Spatial

export(NodePath) var target_path
#var target
export var speed = 50
export(NodePath) var ik_path
var ik
export(NodePath) var ray_vertical_path
var ray_y
export(NodePath) var marker_path
export(NodePath) var ray_horizontal_path
var ray_z
export(NodePath) var marker2_path

onready var marker = get_node(marker_path)
onready var marker2 = get_node(marker2_path)
onready var skeleton = get_node("Armature")
onready var target = get_node(target_path)

var is_marker1_under_mouse = false
var is_marker1_dragged = false
var is_camera_dragged = false

func _ready():
#	target = get_node(target_path)
	ik = get_node(ik_path)
#	ik.start() # used for the SkeletonIK node
	ray_y = get_node(ray_vertical_path)
	marker.show()
	ray_z = get_node(ray_horizontal_path)
	marker2.show()
	
	set_process(true)
	
func _process(delta):
	if Input.is_action_pressed("ui_up"):
		target.translate_object_local(transform.basis.y * delta * speed)
	if Input.is_action_pressed("ui_down"):
		target.translate_object_local(-transform.basis.y * delta * speed)
	if Input.is_action_pressed("ui_left"):
		target.translate_object_local(transform.basis.z * delta * speed)
	if Input.is_action_pressed("ui_right"):
		target.translate_object_local(-transform.basis.z * delta * speed)
		
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
		
	ik.calcIK(90, 75, 0, 90, 90, 90)
	
func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed() and is_marker1_under_mouse:
		is_marker1_dragged = true
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		print("Marker1 being dragged")
	elif event is InputEventMouseButton and !event.is_pressed() and is_marker1_dragged:
		is_marker1_dragged = false
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		var positionOnScreen = $FocusPoint/Camera.unproject_position(marker.get_global_transform().origin)
		get_viewport().warp_mouse(positionOnScreen)
		print("Marker1 released")
	elif event is InputEventMouseMotion and is_marker1_dragged:
		print(event.relative)
		skeleton.rotate_object_local(Vector3(0,1,0), event.relative.x * PI/360)
	elif event is InputEventMouseButton and event.get_button_index() == 3 and event.is_pressed():
		is_camera_dragged = true
	elif event is InputEventMouseButton and event.get_button_index() == 3 and !event.is_pressed():
		is_camera_dragged = false
	elif event is InputEventMouseMotion and is_camera_dragged:
		$FocusPoint/Gimbal.rotate_object_local(Vector3(0,0,1), event.relative.y * PI/360)
		$FocusPoint.rotate_object_local(Vector3(0,-1,0), event.relative.x * PI/360)


func _on_MarkerVertical_mouse_entered():
	print("Entered marker1")
	is_marker1_under_mouse = true
	
func _on_MarkerVertical_mouse_exited():
	print("Exited marker1")
	is_marker1_under_mouse = false

func _on_VerticalGuide_mouse_entered():
	print("Working!!")

func _on_ArmIK_shoulder_servo_moved(shoulder):
#	print(shoulder)
	$"Armature/002-Shoulder2".set_rotation_degrees(Vector3(shoulder-90, 0, 0))

func _on_ArmIK_elbow_servo_moved(elbow):
#	print(elbow)
	$"Armature/002-Shoulder2/Spatial".set_rotation_degrees(Vector3(elbow-90, 0, 0)) 

func _on_ArmIK_wrist_servo_moved(wrist):
#	print(wrist)
	$"Armature/002-Shoulder2/Spatial/003-Arm2/Spatial2".set_rotation_degrees(Vector3(90-wrist, 0, 0)) 
