extends KinematicBody

# Hello Logans NES

export var ACCEL = 2
export var SPEED = 70
export var TURN = 0.1
export var MAXTURN = 2
export var FRIC = 1.05
export var WEIGHT = 0.7

var MAXFALL = WEIGHT*10

enum {FREE = -2, NEUTRAL = 0, FORWARD = 1}
const BACKWARD = -0.3333

var joy_dir = 0
var accel_turn = 0
var accel_speed = 0
var motion = Vector3()
var drive_state = NEUTRAL
var drive_dir = 0
var drive_timer = 0

func _physics_process(delta):
	var vec_angle = rotation_degrees.y
	var mesh_angle = deg2rad(rotation_degrees.y)
	
	# Gravities
	if (!is_on_floor()):
		if (motion.y < MAXFALL):
			motion.y -= WEIGHT
		else:
			motion.y = -MAXFALL
	else:
		motion.y = 0
	
	# Turnings
	  
	joy_dir = Input.get_joy_axis(1,0)
	
#	if (Input.is_action_just_pressed("L")):
#		joy_dir = -1
#	if (Input.is_action_just_pressed("R")):
#		joy_dir = 1
#
#	if (Input.is_action_just_released("L") || Input.is_action_just_released("R")):
#		accel_turn = 0
#		if (Input.is_action_pressed("L")):
#			joy_dir = -1
#		elif (Input.is_action_pressed("R")):
#			joy_dir = 1
#		else:
#			joy_dir = 0
	
	if (drive_state != NEUTRAL):
		if ((joy_dir > 0 and accel_turn < joy_dir*MAXTURN) or (joy_dir < 0 and accel_turn > joy_dir*MAXTURN)):
			accel_turn += joy_dir*TURN
		else:
			accel_turn = joy_dir*MAXTURN
		if (accel_turn != 0):
			rotation_degrees.y -= accel_turn
	
	$Mesh/WheelL.rotation_degrees.y = (-accel_turn*10)*drive_dir
	$Mesh/WheelR.rotation_degrees.y = (-accel_turn*10)*drive_dir
	$Mesh.rotation_degrees.y = -accel_turn*drive_dir
	
	# Acceleratings
	
	if (Input.is_action_just_pressed("A")):
		drive_state = FORWARD
		drive_dir = 1
	if (Input.is_action_just_pressed("B")):
		drive_state = BACKWARD
		drive_dir = -1
	
	if (Input.is_action_just_released("A") || Input.is_action_just_released("B")):
		if (Input.is_action_pressed("A")):
			drive_state = FORWARD
			drive_dir = 1
		if (Input.is_action_pressed("B")):
			drive_state = BACKWARD
			drive_dir = -1
	if (!Input.is_action_pressed("A") and !Input.is_action_pressed("B")):
		drive_dir = 0
		if (accel_speed != 0):
			drive_state = FREE
		else:
			drive_state = NEUTRAL
	
	if (Input.is_action_pressed("A") or Input.is_action_pressed("B")):
		drive_timer += 1
	else:
		drive_timer = 0
	
	if (drive_dir != 0):
		accel_speed += drive_dir*ACCEL
		accel_speed = clamp(accel_speed, -SPEED/3, SPEED)
	else:
		if (accel_speed > 1 or accel_speed < -1):
			accel_speed /= FRIC
		else:
			accel_speed = 0
	
	motion.x = sin(mesh_angle)*(accel_speed)
	motion.z = cos(mesh_angle)*(accel_speed)
	
	move_and_slide(motion, Vector3(0,1,0))
