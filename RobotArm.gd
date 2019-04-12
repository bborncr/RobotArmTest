extends Spatial

export(NodePath) var target_path
var target
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

func _ready():
	target = get_node(target_path)
	ik = get_node(ik_path)
	ik.start()
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
	if Input.is_action_pressed("rotate_left"):
		skeleton.rotate_object_local(Vector3(0,1,0), PI/180)
	if Input.is_action_pressed("rotate_right"):
		skeleton.rotate_object_local(Vector3(0,-1,0), PI/180)
		
	if ray_y.is_enabled() and ray_y.is_colliding():
		var collision_point = ray_y.get_collision_point()
		marker.set_translation(collision_point)
	
	if ray_z.is_enabled() and ray_z.is_colliding():
		var vertical_pos = ray_z.get_collision_point().y
		var marker_pos = Vector3()
		marker_pos.x = 0
		marker_pos.y = vertical_pos
		marker_pos.z = 0
		print(marker_pos)
		marker2.set_translation(marker_pos)