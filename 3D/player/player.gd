extends Node3D

const MOUSE_SENSITIVITY = 0.20

@onready var body = $Body
#@onready var body_shape = $Body/BodyShape
@onready var head = $Body/Head
#@onready var dir_checks = $DirChecks
#@onready var hud = $HUD

@onready var step_timer = $StepTimer
@onready var step = $Step

var direction = Vector3()

#signal scroll(direction)
#signal direction_changed(direction)
#signal crouch
#signal uncrouch
#signal jump

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#get_input()

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		body.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		
	#if event is InputEventMouseButton and event.is_pressed():
	#	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
	#		emit_signal("scroll", "up")
	#	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
	#		emit_signal("scroll", "down")
#
#func get_input():
	#
	#direction = Vector3(0, 0, 0)
	#
	##I'm walkin here!
	if Input.is_action_pressed("movement_forward"):
		direction -= body.transform.basis.z
	elif Input.is_action_pressed("movement_backward"):
		direction += body.transform.basis.z
	if Input.is_action_pressed("movement_left"):
		direction -= body.transform.basis.x
	elif Input.is_action_pressed("movement_right"):
		direction += body.transform.basis.x
		
	#direction = direction.normalized()
	
	#Step SFX
	if direction != Vector3(0, 0, 0) and body.is_on_floor() and step_timer.time_left <= 0:
		step_timer.start(0.25)
		step.play()
		#play_sample(step)
	
	emit_signal("direction_changed", direction)

	##Jumpy
	#if Input.is_action_just_pressed("movement_jump"):
		#emit_signal("jump")
		#
	##Crouchy
	#if Input.is_action_just_pressed("movement_crouch"):
		#emit_signal("crouch")
	#elif Input.is_action_just_released("movement_crouch"):
		#emit_signal("uncrouch")
		#
	##Cursor Capture
	#if Input.is_action_just_pressed("ui_switch"):
		#if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		#else:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#
			#
	##Close window
	#if Input.is_action_just_pressed("ui_cancel"):
		#get_tree().quit()
