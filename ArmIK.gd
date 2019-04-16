extends Node

const rtod = 57.295779
export var a = 100
export var b = 100

signal base_servo_moved
signal shoulder_servo_moved
signal elbow_servo_moved
signal wrist_servo_moved
signal grip_servo_moved

func _ready():
	pass # Replace with function body.

# Arm positioning routine utilizing inverse kinematics
# z is base angle, y vertical distance from base, x is horizontal distance
func calcIK(x, y, z, g, wa, wr):
	var M = sqrt((y * y) + (x * x))
#	print(M)
	if M <= 0:
		return -1
	var A1 = atan2(y, x)
#	print(A1)
	var A2 = acos(((a * a) - (b * b) + (M * M)) / ((a * 2) * M))
	var elbow = acos(((a * a) + (b * b) - (M * M))/((a * 2) * b))
	var shoulder = A1 + A2
	elbow = elbow * rtod
	shoulder = shoulder * rtod
	while int(elbow) <= 0 or int(shoulder) <= 0:
    	return -1
	var wrist = abs(wa - elbow - shoulder);
	emit_signal("base_servo_moved", z)
	emit_signal("shoulder_servo_moved", shoulder)
	emit_signal("elbow_servo_moved", elbow)
	emit_signal("wrist_servo_moved", wrist)
	emit_signal("grip_servo_moved", g)

#  servo1.setValue(Shoulder);
#  servo2.setValue(180-Elbow);
#  servo3.setValue(180-Wris);
	return 1