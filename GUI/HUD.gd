extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()
onready var PortList = $SerialSettings/VBoxContainer/HBoxPort/PortList
#helper node
onready var com=$Com
#use it as node since script alone won't have the editor help

var port

signal servo_manually_moved
signal is_ik_enabled

var _base
var _shoulder
var _elbow
var _wrist
var _gripper
var update = false

func _ready():
	# Scan for serial ports and add select the first in the list
	for index in PORT.list_ports():
		PortList.add_item(str(index))
	if PortList.get_item_text(0) != null:
		port = PortList.get_item_text(0)
		print(port)

func _process(delta):
	if update:
		emit_signal("servo_manually_moved", _base, _shoulder, _elbow, _wrist, _gripper)
#		print(_base)
		update = false
		
#_physics_process may lag with lots of characters, but is the simplest way
#for best speed, you can use a thread
#do not use _process due to fps being too high
#func _physics_process(delta): 
#	if PORT.get_available()>0:
#		for i in range(PORT.get_available()):
#			$RichTextLabel.add_text(PORT.read())

func _on_ArmIK_servo_moved(base, shoulder, elbow, wrist, gripper):
	_base = int(base)
	_shoulder = int(shoulder)
	_elbow = int(elbow)
	_wrist = int(wrist)
	_gripper = int(gripper)
	$ServoPanel/VBox/BaseSlider/HSlider.set_value(_base)
	send_message(0, 180-_base)
	$ServoPanel/VBox/ShoulderSlider/HSlider.set_value(_shoulder)
	send_message(1, _shoulder)
	$ServoPanel/VBox/ElbowSlider/HSlider.set_value(_elbow)
	send_message(2, 180-_elbow)
	$ServoPanel/VBox/WristSlider/HSlider.set_value(_wrist)
	send_message(3, _wrist-5)
	$ServoPanel/VBox/GripperSlider/HSlider.set_value(_gripper)
	send_message(4, _gripper)

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
		
	
func _on_UpdateButton_pressed(): #Updates the port list
	PortList.clear()
	PortList.add_item("Select Port")
	for index in PORT.list_ports():
		PortList.add_item(str(index))

func _on_PortList_item_selected(ID):
	port = PortList.get_item_text(ID)
	
func send_message(servo, pos):
	var msg
	var format_message = "%s,%s"
	msg = format_message % [String(servo), String(pos)]
#	print(msg)	
	msg += com.endline
	PORT.write(msg)


func _on_HUD_servo_manually_moved(base, shoulder, elbow, wrist, gripper):
	_base = base
	_shoulder = shoulder
	_elbow = elbow
	_wrist = wrist
	_gripper = gripper
	$ServoPanel/VBox/BaseSlider/HSlider.set_value(_base)
	send_message(0, _base)
	$ServoPanel/VBox/ShoulderSlider/HSlider.set_value(_shoulder)
	send_message(1, _shoulder)
	$ServoPanel/VBox/ElbowSlider/HSlider.set_value(_elbow)
	send_message(2, 180-_elbow) # elbow servo is inverted
	$ServoPanel/VBox/WristSlider/HSlider.set_value(_wrist)
	send_message(3, _wrist)
	$ServoPanel/VBox/GripperSlider/HSlider.set_value(_gripper)
	send_message(4, _gripper)


func _on_Connect_pressed():
	set_physics_process(false)
	PORT.close()
	if port!=null:
		PORT.open(port,38400,1000)
		print("connected")
		$SerialSettings.hide()
	else:
		print("You must select a port first")
	set_physics_process(true)