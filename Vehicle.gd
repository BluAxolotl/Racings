extends KinematicBody

export var ACCEL = 3
export var SPEED = 90
export var TURN = 0.1
export var MAXTURN = 2
export var DRIFT_TURN = 0.1
export var MAX_DRIFT = 8
export var FRIC = 1.05
export var WEIGHT = 0.7

var MAXFALL = WEIGHT*10

enum {FREE = -2, NEUTRAL = 0, FORWARD = 1}
const BACKWARD = -0.3333

var joy_dir = 0
var prev_joy_dir = 0
var accel_turn = 0
var drift_dir = 0
var drifting = false
var drift_timer = 0
var drift_accel = 0
var accel_speed = 0
var motion = Vector3()
var drive_state = NEUTRAL
var drive_dir = 0
var drive_timer = 0

var frame = 0

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
	
	# Driftings
		
		if (Input.is_action_pressed("DRIFT")):
			drift_timer += 1
			drifting = true
		else:
			drift_dir = 0
			drift_timer = 0
			drifting = false
		
		if (drift_timer == 1):
			accel_turn = 0
			drift_accel = -1
			drift_dir = joy_dir
	
	# Turnings
	  
	joy_dir = round(Input.get_joy_axis(1,0))
	
	if (joy_dir != prev_joy_dir):
		if (drifting):
			pass
#			drift_accel /= 2
		else:
			accel_turn /= 2
		
	
	if (drifting):
		if ((joy_dir > 0 and drift_accel < joy_dir*MAX_DRIFT) or (joy_dir < 0 and drift_accel > joy_dir*MAX_DRIFT)):
			drift_accel += (joy_dir*DRIFT_TURN)
		else:
			drift_accel = (joy_dir*MAX_DRIFT)
		accel_turn = drift_dir - ((-drift_accel)/(MAX_DRIFT+2))
#		print("accel_turn: %s\ndrift_dir: %s\ndrift_ppaDDADDAAD accel: %s" % [ accel_turn, drift_dir, drift_accel ])
	else:
		if (drive_state != NEUTRAL and joy_dir != 0):
			if ((joy_dir > 0 and accel_turn < joy_dir*MAXTURN) or (joy_dir < 0 and accel_turn > joy_dir*MAXTURN)):
				accel_turn += (joy_dir*TURN)
			else:
				accel_turn = (joy_dir*MAXTURN)
		elif (abs(accel_turn) > 0.4):
			accel_turn /= 1.1
		else:
			accel_turn = 0
	
	rotation_degrees.y -= accel_turn
	
	if (!drifting):
		$Mesh/WheelL.rotation_degrees.y = (-accel_turn*10)*drive_dir
		$Mesh/WheelR.rotation_degrees.y = (-accel_turn*10)*drive_dir
		$Mesh.rotation_degrees.y = -accel_turn*drive_dir
	else:
		$Mesh/WheelL.rotation_degrees.y = (-accel_turn*20)*drive_dir
		$Mesh/WheelR.rotation_degrees.y = (-accel_turn*20)*drive_dir
		$Mesh.rotation_degrees.y = (-accel_turn*(drive_dir*10))-(drift_dir*4)
	
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
			
	prev_joy_dir = joy_dir
	
	motion.x = sin(mesh_angle)*(accel_speed)
	motion.z = cos(mesh_angle)*(accel_speed)
	
	move_and_slide(motion, Vector3(0,1,0))
	frame += 1
