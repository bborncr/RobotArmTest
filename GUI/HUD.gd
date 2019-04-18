extends Control

const SERCOMM = preload("res://bin/GDsercomm.gdns")
onready var PORT = SERCOMM.new()

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
	#adding the baudrates options
	$SerialSettings/VBoxContainer/OptionButton.add_item("")
	for index in com.baud_list: #first use of com helper
		$SerialSettings/VBoxContainer/OptionButton.add_item(str(index))

func _process(delta):
	if update:
		emit_signal("servo_manually_moved", _base, _shoulder, _elbow, _wrist, _gripper)
		update = false
		
#_physics_process may lag with lots of characters, but is the simplest way
#for best speed, you can use a thread
#do not use _process due to fps being too high
func _physics_process(delta): 
	if PORT.get_available()>0:
		for i in range(PORT.get_available()):
			$RichTextLabel.add_text(PORT.read())

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
		
func _on_OptionButton_item_selected(ID):
	set_physics_process(false)
	PORT.close()
	if port!=null and ID!=0:
		PORT.open(port,int($SerialSettings/VBoxContainer/OptionButton.get_item_text(ID)),1000)
	else:
		print("You must select a port first")
	set_physics_process(true)
	
func _on_UpdateButton_pressed(): #Updates the port list
	$SerialSettings/VBoxContainer/PortList.clear()
	$SerialSettings/VBoxContainer/PortList.add_item("Select Port")
	for index in PORT.list_ports():
		$SerialSettings/VBoxContainer/PortList.add_item(str(index))

func _on_PortList_item_selected(ID):
	port=$SerialSettings/VBoxContainer/PortList.get_item_text(ID)
	$SerialSettings/VBoxContainer/OptionButton.select(0)
	
func send_message(msg):
	msg += com.endline
	print(msg)
	PORT.write(msg) #write function, please use only ascii


func _on_Button_pressed():
	send_message(str(12))
