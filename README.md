# Robot Arm Controller using Godot
The idea is to use a 3D representation of a robot arm in Godot as an interface to control and program sequences and animations of an Arduino based robot arm.
## Controls
* Use the middle mouse button to rotate camera
* Grab the 3D Gizmo to change the position of the arm
* Toggle off the Inverse Kinematics and use the sliders to control the individual servos
* Click on the `Port Config` button and select the serial port
* Load and save poses
* Add poses to the pose editor
* Right click on the pose editor for context menu

## Serial Protocol
The serial port is currectly set to 38400 baud.

<servo_number,servo_position><new_line>

Example:

`0,90<newline>` sets servo 0 to 90 degrees

## Screenshot
![Screenshot](https://github.com/bborncr/RobotArmTest/blob/master/screenshots/RobotArmScreenshot1.png)
