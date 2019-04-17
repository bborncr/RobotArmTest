extends Control

signal servo_manually_moved
signal is_ik_enabled

var _base
var _shoulder
var _elbow
var _wrist
var _gripper
var update = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	if update:
		emit_signal("servo_manually_moved", _base, _shoulder, _elbow, _wrist, _gripper)
		update = false

func _on_ArmIK_servo_moved(base, shoulder, elbow, wrist, gripper):
	_base = base
	_shoulder = shoulder
	_elbow = elbow
	_wrist = wrist
	_gripper = gripper
	$ServoPanel/VBox/BaseSlider/HSlider.set_value(_base)
	$ServoPanel/VBox/ShoulderSlider/HSlider.set_value(_shoulder)
	$ServoPanel/VBox/ElbowSlider/HSlider.set_value(_elbow)
	$ServoPanel/VBox/WristSlider/HSlider.set_value(_wrist)
	$ServoPanel/VBox/GripperSlider/HSlider.set_value(_gripper)

func _on_gripper_value_changed(value):
	_gripper = value
	update = true

func _on_wrist_value_changed(value):
	_wrist = value
	update = true

func _on_elbow_value_changed(value):
	_elbow = value
	update = true

func _on_shoulder_value_changed(value):
	_shoulder = value
	update = true

func _on_base_value_changed(value):
	_base = value
	update = true

func _on_SelectIK_toggled(button_pressed):
	if button_pressed:
		emit_signal("is_ik_enabled", true)
	else:
		emit_signal("is_ik_enabled", false)
