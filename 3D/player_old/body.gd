extends CharacterBody3D

signal landed()
signal fallen()
signal send_height(height)

const GRAVITY = 70

const JUMP_POWER = 25
const AIR_ACCEL = 1
const NORMAL_ACCEL = 6
const SPEED_KILL = 8
const MAX_SLOPE_ANGLE = 80
const CROUCH = 1.75
const NORM_SPEED = 15
const NORM_DIVE_SPEED = 120
const NORM_HEIGHT = 3
const STEP_POWER = 5
const DEATH_POINT = -100

var h_accel = 6

var move_speed = NORM_SPEED
#var velocity = Vector3()
var direction = Vector3()
var movement = Vector3()
var h_velocity = Vector3()
var snap = Vector3()
var gravity_vec = Vector3()
var restore_point = Vector3(0, 0, 0)

const NORM_JUMP_QUEUE = 0.15
var jump_queue = NORM_JUMP_QUEUE
var jump = false

var in_air = false

var crouching = false

@onready var body_shape = $BodyShape
@onready var head = $Head


# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().root.ready
	restore_point = global_transform.origin
	emit_signal("send_height", body_shape.scale.y)


func _physics_process(delta):
	if jump:
		if is_on_floor():
			#move_speed = move_speed * 2
			gravity_vec = Vector3.UP * JUMP_POWER
			snap = Vector3(0, 0, 0)
		if jump_queue <= 0:
			jump = false
		jump_queue -= delta
		
	if global_transform.origin.y < DEATH_POINT:
		emit_signal("fallen")
		global_transform.origin = restore_point
		h_velocity = Vector3 (0, 0, 0)
		rotation = Vector3 (0, 0, 0)
		head.rotation = Vector3(0, 0, 0)
	
	h_velocity = h_velocity.lerp(direction * move_speed, h_accel * delta)
	movement.z = h_velocity.z + gravity_vec.z
	movement.x = h_velocity.x + gravity_vec.x
	movement.y = gravity_vec.y
	
	#TODO: This is probably fucked up and borked big time.
	floor_snap_length = snap.y
	movement = move_and_slide()
	#movement = move_and_slide(movement, snap, Vector3.UP, false, 4, PI/4)
	
	print()
	
	if not is_on_floor():
		in_air = true
		gravity_vec += Vector3.DOWN * GRAVITY * delta
		h_accel = AIR_ACCEL
		
		#Diving!
		if crouching:
			if movement.y < 0:
				move_speed = NORM_DIVE_SPEED
			elif !is_on_wall():
				h_velocity = h_velocity.linear_interpolate(Vector3 (0, 0, 0), SPEED_KILL * delta)
				move_speed = NORM_SPEED / 100
			
	else:
		if in_air:
			emit_signal("landed")
			in_air = false
		gravity_vec = -get_floor_normal()
		snap = -get_floor_normal()
		move_speed = NORM_SPEED
		h_accel = NORMAL_ACCEL
		
		if crouching: move_speed = NORM_SPEED / 3.5
		
	if is_on_ceiling():
		gravity_vec.y = -0.1
		


func _on_Player_direction_changed(d):
	direction = d


func _on_Player_jump():
	jump = true
	jump_queue = NORM_JUMP_QUEUE

		
#Add move_and_collide offset when crouching and uncrouching to prevent collision bugs
func _on_Player_crouch():
	move_speed = NORM_SPEED / 3.5
	body_shape.scale.y = NORM_HEIGHT / 1.5
	if is_on_floor(): move_and_collide(Vector3(0, -body_shape.scale.y, 0))
	crouching = true
	emit_signal("send_height", body_shape.scale.y)


#Add move_and_collide offset when crouching and uncrouching to prevent collision bugs
func _on_Player_uncrouch():
	move_speed = NORM_SPEED
	body_shape.scale.y = NORM_HEIGHT
	crouching = false
	#if is_on_floor(): move_and_collide(Vector3(0, body_shape.scale.y/9, 0))
	emit_signal("send_height", body_shape.scale.y)


func _on_DirChecks_can_step():
	if is_on_wall() and is_on_floor():
		move_and_collide(Vector3(0, STEP_POWER, 0))
		move_and_collide(Vector3(direction.x/5, 0, direction.z/5))
		move_and_collide(Vector3(0, -100, 0))	

func _on_BodyShape_tree_entered():
	pass
