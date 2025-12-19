extends Node3D

const MOUSE_SENSITIVITY = 0.20

@onready var body = $Body
@onready var body_shape = $Body/BodyShape
@onready var head = $Body/Head
@onready var dir_checks = $DirChecks
@onready var hud = $HUD

@onready var step_timer = $StepTimer
@onready var step = $Step
@onready var hurt = $Hurt
@onready var land = $Land

var direction = Vector3()

signal scroll(direction)
signal direction_changed(direction)
signal crouch
signal uncrouch
signal jump

signal look_object(object, interact)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _process(_delta):
	get_input()


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
		body.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			emit_signal("scroll", "up")
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			emit_signal("scroll", "down")


func get_input():
	
	direction = Vector3(0, 0, 0)
	
	#I'm walkin here!
	if Input.is_action_pressed("movement_forward"):
		direction -= body.transform.basis.z
	elif Input.is_action_pressed("movement_backward"):
		direction += body.transform.basis.z
	if Input.is_action_pressed("movement_left"):
		direction -= body.transform.basis.x
	elif Input.is_action_pressed("movement_right"):
		direction += body.transform.basis.x
		
	#direction = direction.normalized()
	
	if direction != Vector3(0, 0, 0) and body.is_on_floor() and step_timer.time_left <= 0:
		step_timer.start(0.25)
		play_sample(step)
	
	emit_signal("direction_changed", direction)
	
	#Jumpy
	if Input.is_action_just_pressed("movement_jump"):
		emit_signal("jump")
		
	#Crouchy
	if Input.is_action_just_pressed("movement_crouch"):
		emit_signal("crouch")
	elif Input.is_action_just_released("movement_crouch"):
		emit_signal("uncrouch")
		
	#Cursor Capture
	if Input.is_action_just_pressed("ui_switch"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

			
	#Close window
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
			


func _on_Head_look_object(object):
	if Input.is_action_just_pressed("interact_1"):
		emit_signal("look_object", object, true)
		emit_signal("scroll", "reset")
	else:
		emit_signal("look_object", object, false)
		
func play_sample(voice):
	var player = voice.duplicate()
	add_child(player)
	player.play()
	await player.finished
	player.queue_free()

func _on_Body_fallen():
	play_sample(hurt)
	
func _on_Body_landed():
	play_sample(land)

func _on_Main_change_scene(to_location):
	body.restore_point = to_location
