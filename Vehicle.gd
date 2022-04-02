extends KinematicBody

export var ACCEL = 2
export var SPEED = 50
export var TURN = 3
export var MAXTURN = 30
export var FRIC = 1.05
export var WEIGHT = 150

enum {FREE = -2, NEUTRAL = 0, FORWARD = 1}
const BACKWARD = -0.3333

var joy_dir = 0
var accel_turn = 0
var accel_speed = 0
var motion = Vector3()
var drive_state = NEUTRAL

func _physics_process(delta):
	var mesh_angle = deg2rad($kart.rotation_degrees.y)
	
	# Gravities
	motion.y = -WEIGHT
	
	# Turnings
	
	if (Input.is_action_just_pressed("L")):
		joy_dir = -1
	if (Input.is_action_just_pressed("R")):
		joy_dir = 1

	if (Input.is_action_just_released("L") || Input.is_action_just_released("R")):
		if (Input.is_action_pressed("L")):
			joy_dir = -1
		elif (Input.is_action_pressed("R")):
			joy_dir = 1
		else:
			joy_dir = 0
			accel_turn = 0

	if (drive_state != NEUTRAL && joy_dir != 0 && accel_turn != joy_dir*MAXTURN):
		$Mesh.rotation_degrees.y -= joy_dir*TURN
	
	# Acceleratings
	
	if (Input.is_action_pressed("A")):
		drive_state = FORWARD
	if (Input.is_action_pressed("B")):
		drive_state = BACKWARD
	
	if (Input.is_action_just_released("A") || Input.is_action_just_released("B")):
		if (Input.is_action_pressed("A")):
			drive_state = FORWARD
		elif (Input.is_action_pressed("B")):
			drive_state = BACKWARD
	if (!Input.is_action_pressed("A") and !Input.is_action_pressed("B")):
		if (accel_speed != 0):
			drive_state = FREE
		else:
			drive_state = NEUTRAL
	
	print(accel_speed)
	
	if (drive_state != NEUTRAL and drive_state != FREE):
		if (accel_speed < drive_state*SPEED):
			accel_speed += drive_state*ACCEL
		else:
			accel_speed = drive_state*SPEED
	else:
		if (accel_speed > 1 or accel_speed < -1):
			accel_speed /= FRIC
		else:
			accel_speed = 0
	
	motion.x = sin(mesh_angle)*(accel_speed)
	motion.z = cos(mesh_angle)*(accel_speed)
	
	move_and_slide(motion, Vector3(0,1,0))
