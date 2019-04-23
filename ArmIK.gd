extends Node

const rtod = 57.295779
export var a = 100
export var b = 100

signal servo_moved

func _ready():
	pass # Replace with function body.

# Arm positioning routine utilizing inverse kinematics
# z is base angle, y vertical distance from base, x is horizontal distance
func calcIK(x, y, base, g, wa, wr):
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
	emit_signal("servo_moved", base, shoulder, elbow, wrist, g)
	return 1