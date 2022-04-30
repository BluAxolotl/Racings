extends KinematicBody

export var ACCEL = 3
export var SPEED = 90
export var TURN = 0.07
export var MAXTURN = 1.5
export var DRIFT_STAT = 0
export var DRIFT_TURN = 0.1
export var MAX_DRIFT = 4
export var FRIC = 1.05
export var WEIGHT = 0.7
export var MAX_BOOST = 300

var MAXFALL = WEIGHT*10

enum {FREE = -2, NEUTRAL = 0, FORWARD = 1}
const BACKWARD = -0.3333

var joy_dir = 0
var last_joy = 0
var prev_joy_dir = 0
var accel_turn = 0
var drift_dir = 0
var drifting = false
var drift_timer = 0
var drift_accel = 0
var accel_speed = 0
var boost_speed = 0
var motion = Vector3()
var drive_state = NEUTRAL
var drive_dir = 0
var drive_timer = 0

var frame = 0

func boost(x):
	Globals.tween(self, "TRANS_CUBIC", 2, "boost_speed", x, 0, 2)

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
	if (Input.is_action_pressed("DRIFT") and drift_timer > 50):
		print("WOWAJODFJIOWJIOWOW")
	
	if (Input.is_action_just_released("DRIFT") and drift_timer > 50):
		print("\n\nWOW!\n\n")
		boost(100)
	
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
	
	# """Itemings"""
	if (Input.is_action_just_pressed("SELECT")):
		boost(200)
	
	# Turnings
	var temp_joy = round(Input.get_joy_axis(1,0))
	if (last_joy != temp_joy):
		joy_dir = temp_joy
		last_joy = joy_dir
	
	if (Input.is_action_just_pressed("R")):
		joy_dir = 1
	if (Input.is_action_just_pressed("L")):
		joy_dir = -1
	if (Input.is_action_just_released("R") or Input.is_action_just_released("L")):
		joy_dir = 0
		if (Input.is_action_pressed("R")):
			joy_dir = 1
		if (Input.is_action_pressed("L")):
			joy_dir = -1
	
	if (joy_dir != prev_joy_dir):
		if (drifting):
			pass
#			drift_accel /= 2
		else:
			accel_turn /= 2
		
	
	if (drifting):
		drift_accel += (joy_dir*DRIFT_TURN)
		drift_accel = clamp(drift_accel, -MAX_DRIFT, MAX_DRIFT)
#		if ( ( (joy_dir > 0 and drift_accel < joy_dir*MAX_DRIFT) or (joy_dir < 0 and drift_accel > joy_dir*MAX_DRIFT) ) and drift_timer > DRIFT_STAT):
#			print(">>> DRIFT POWER >>>")
#			drift_accel += (joy_dir*DRIFT_TURN)
#		else:
#			drift_accel = (joy_dir*MAX_DRIFT)
		accel_turn = drift_dir - ((-drift_accel)/(MAX_DRIFT+2))
#		print("accel_turn: %s\ndrift_dir: %s\ndrift_accel: %s" % [ accel_turn, drift_dir, drift_accel ])
	else:
		if (drive_state != NEUTRAL and joy_dir != 0):
			accel_turn += (joy_dir*TURN)
			accel_turn = clamp(accel_turn, -MAXTURN, MAXTURN)
#			if ((joy_dir > 0 and accel_turn < joy_dir*MAXTURN) or (joy_dir < 0 and accel_turn > joy_dir*MAXTURN)):
#				accel_turn += (joy_dir*TURN)
#			else:
#				accel_turn = (joy_dir*MAXTURN)
		elif (abs(accel_turn) > 0.4):
			accel_turn /= 1.1
		else:
			accel_turn = 0
	
	if (drift_timer != 0 and drift_timer < DRIFT_STAT):
		var start_amount = ( sin( ( (drift_timer) * PI ) / (DRIFT_STAT) ) * 1.5 ) * drift_dir
		print("drift_timer: %s\nstart_amount: %s" % [drift_timer, start_amount])
		accel_turn -= start_amount
	
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
		if (drifting and drive_dir == -1):
			drive_dir = 0.1
		accel_speed += drive_dir*ACCEL
		accel_speed = clamp(accel_speed, -SPEED/3, SPEED)
	else:
		if (accel_speed > 1 or accel_speed < -1):
			accel_speed /= FRIC
		else:
			accel_speed = 0
			
	prev_joy_dir = joy_dir
	
	boost_speed = clamp(boost_speed, -MAX_BOOST, MAX_BOOST)
	
	print(boost_speed)
	
	motion.x = sin(mesh_angle)*(accel_speed+boost_speed)
	motion.z = cos(mesh_angle)*(accel_speed+boost_speed)
	
	move_and_slide(motion, Vector3(0,1,0))
	frame += 1
