extends Node

const rtod = 57.295779
export var a = 95.25
export var b = 107.95

var shoulder
var elbow
var wrist

signal shoulder_servo_moved
signal elbow_servo_moved
signal wrist_servo_moved

func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

# Arm positioning routine utilizing inverse kinematics
# z is base angle, y vertical distance from base, x is horizontal distance
func ArmIK(x, y, z, g, wa, wr):
	var M = sqrt((y * y) + (x * x))
	if M <= 0:
		return -1
	var A1 = atan(y / x)
	var A2 = acos((a * a - b * b + M * M) / ((a * 2) * M))
	var elbow = acos((a * a + b * b - M * M)/((a * 2) * b))
	shoulder = A1 + A2
	elbow = elbow * rtod
	shoulder = shoulder * rtod
	while ( int(elbow) <= 0 || int(shoulder) <= 0):
    	return -1
	var wrist = abs(wa - elbow - shoulder);
	emit_signal("shoulder_servo_moved", shoulder)
	emit_signal("elbow_servo_moved", elbow)
	emit_signal("wrist_servo_moved", wrist)
#  servo1.setValue(Shoulder);
#  servo2.setValue(180-Elbow);
#  servo3.setValue(180-Wris);
	return 1