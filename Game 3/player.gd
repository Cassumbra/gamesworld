extends CharacterBody2D

@export var foreground: TileMapLayer
@export var backwalls: TileMapLayer

const SPEED = 60.0
const ACCEL = 200.0
const DEACCEL = 300.0
const JUMP_VELOCITY = -50.0
const JUMP_HOVER = -15.0
const GRAVITY = Vector2(0, 400)


var in_air_last_frame = false
var respawn_position = Vector2.ZERO

var can_start_float = false
var is_floating = false
var float_direction = Vector2.ZERO
var float_velocity = 0.0

var float_tween: Tween
const FLOAT_TWEEN_MIN_VOLUME = -50
const FLOAT_TWEEN_TIME = 1

func _ready() -> void:
	respawn_position = position
	float_tween = get_tree().create_tween()
	float_tween.tween_property($SpeakerFloat, "volume_db", FLOAT_TWEEN_MIN_VOLUME, FLOAT_TWEEN_TIME)
	float_tween.stop()

func _physics_process(delta: float) -> void:
	var has_died = false

	
	#if position.y > 140:
		#has_died = true
		
		#$SpeakerDie.play()
		#position = Vector2(2.0, -3.0)
	
	if is_on_floor() && in_air_last_frame:
		$SpeakerLand.play()
	
	# Add the gravity.
	if not is_on_floor():
		in_air_last_frame = true
		velocity += GRAVITY * delta
	else:
		in_air_last_frame = false
		can_start_float = true
		
		

	# Jump buffering.
	if Input.is_action_just_pressed("primary") && !is_on_floor():
		$TimerJumpBuffer.start()
	
	# Handle jump.
	if (Input.is_action_just_pressed("primary") || !$TimerJumpBuffer.is_stopped()) && is_on_floor():
		velocity.y = JUMP_VELOCITY
		$TimerJump.start()
		
	if Input.is_action_pressed("primary") && !$TimerJump.is_stopped():
		velocity.y += JUMP_HOVER


		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal := Input.get_axis("left", "right")
	var vertical := Input.get_axis("up", "down")
	# Fast deaccel
	if horizontal * -1 == sign(velocity.x):
		velocity.x = move_toward(velocity.x, 0, (DEACCEL + ACCEL) * delta)
	# Regular movement
	elif horizontal == 1 && velocity.x < SPEED:
		velocity.x = move_toward(velocity.x, SPEED, ACCEL * delta)
	elif horizontal == -1 && velocity.x > -SPEED:
		velocity.x = move_toward(velocity.x, -SPEED, ACCEL * delta)
	# Deaccel
	else:
		var deaccel_reduction = 1
		if !is_on_floor():
			deaccel_reduction *= 10
			
		if sign(horizontal) == sign(velocity.x):
			deaccel_reduction *= 10
		
		velocity.x = move_toward(velocity.x, 0, DEACCEL/deaccel_reduction * delta)
		

		
	# Handle float.
	if Input.is_action_just_pressed("secondary") && can_start_float:
		is_floating = true
		can_start_float = false
		float_direction = Vector2(horizontal, vertical)
		var dampening = 1 - (abs(angle_difference(float_direction.angle(), velocity.angle())) / PI)
		float_velocity = max(velocity.length() * dampening, SPEED)
		$TimerFloat.start()
		
		if horizontal * vertical == 0:
			$ParticlesFloat.direction = Vector2(vertical, horizontal)
		else:
			$ParticlesFloat.direction = Vector2(-horizontal, vertical)
		
		$ParticlesFloatInverse.direction = $ParticlesFloat.direction * -1
		$ParticlesFloat.emitting = true
		$ParticlesFloatInverse.emitting = true
		
		$SpeakerFloat.volume_db = -8
		$SpeakerFloat.play()
		float_tween.stop()
		
	if (Input.is_action_just_released("secondary") || $TimerFloat.is_stopped()) && is_floating == true:
		is_floating = false
		$ParticlesFloat.emitting = false
		$ParticlesFloatInverse.emitting = false
		
		float_tween = get_tree().create_tween()
		float_tween.tween_property($SpeakerFloat, "volume_db", FLOAT_TWEEN_MIN_VOLUME, FLOAT_TWEEN_TIME)
		
	
	if is_floating:
		velocity = float_velocity * float_direction
		
	if velocity.x != 0 && is_on_floor():
		$AnimatedSprite2D.play("walking")
		if $TimerStep.is_stopped():
			$SpeakerStep.play()
			$TimerStep.start()
	else:
		$AnimatedSprite2D.pause()
		$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	

	move_and_slide()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		
		var collided_tile = foreground.local_to_map(collision.get_position()) #+ -Vector2i(collision.get_normal())
		var data = foreground.get_cell_tile_data(collided_tile)
		
		if data:
			#TODO: Can this be a match statement?
			if data.get_custom_data("Hurts"):
				has_died = true
			
				
	if $Area.overlaps_body(foreground):
		var collided_tile = foreground.local_to_map(position)
		var data = foreground.get_cell_tile_data(collided_tile)
		
		if data:
			if data.get_custom_data("Flag"):
				if collided_tile != foreground.local_to_map(respawn_position):
					var last_flag = foreground.local_to_map(respawn_position)
					var data_2 = foreground.get_cell_tile_data(last_flag)
					if data_2:
						foreground.set_cell(last_flag, 0, data_2.get_custom_data("Breaks Into"))
					respawn_position = position
					foreground.set_cell(collided_tile, 0, data.get_custom_data("Breaks Into"))
			elif data.get_custom_data("Victory"):
				foreground.erase_cell(collided_tile)
				process_mode = Node.PROCESS_MODE_DISABLED
				$CanvasLayer.visible = true
	
	if has_died:
		$SpeakerDie.play()
		velocity = Vector2.ZERO
		position = respawn_position
