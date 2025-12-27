extends CharacterBody3D

const MOUSE_SENSITIVITY = 0.20

@onready var body_shape = $BodyShape
@onready var head = $Head

@onready var head_check = $HeadCheck
@onready var body_check = $BodyCheck
@onready var foot_check = $FootCheck

#@onready var hud = $HUD

@onready var step_timer = $StepTimer
@onready var step = $Step

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	head.position.y = (body_shape.get_shape().height / 2.0) * 0.75
	# TODO: make this into some sort of function that we call in _ready() as well as whenever we crouch/uncrouch
	head_check.position.y = body_shape.get_shape().height / 2.0
	#body_check.position.y = -body_shape.get_shape().height / 4.0
	foot_check.position.y = -body_shape.get_shape().height / 2.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#get_input()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var base_direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		
	head_check.target_position = base_direction * (body_shape.get_shape().radius + 0.25)
	body_check.target_position = base_direction * (body_shape.get_shape().radius + 0.25)
	foot_check.target_position = base_direction * (body_shape.get_shape().radius + 0.25)
	
	#if (!head_check.is_colliding() and !body_check.is_colliding()
	#and foot_check.is_colliding() and foot_check.get_collision_normal().y == 0.0):
	#	print("Can step!: %s" % foot_check.get_collision_normal())
		

	move_and_slide()
	for collision_i in get_slide_collision_count():
		var collision := get_slide_collision(collision_i)
		if (is_on_floor()
		and !head_check.is_colliding() and !body_check.is_colliding() and foot_check.is_colliding()
		and foot_check.get_collision_normal().y == 0.0):
			# Fuck you. MY FACE WHEN 0.0 != 0.0 !!!!!!!!
			if collision.get_normal().y > -0.00001 and collision.get_normal().y < 0.00001:
				move_and_collide(Vector3(0.0, body_shape.get_shape().height, 0.0))
				move_and_collide(direction * 0.05)
				move_and_collide(Vector3(0.0, -body_shape.get_shape().height, 0.0))
	
	Global3d.player_pos = position
	
	if direction != Vector3(0, 0, 0) and is_on_floor() and step_timer.time_left <= 0:
		step_timer.start(0.25)
		step.play()
		#play_sample(step)
