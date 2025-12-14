extends CharacterBody2D

@export var foreground: TileMapLayer
@export var backwalls: TileMapLayer

const SPEED = 60.0
const JUMP_VELOCITY = -150.0
const GRAVITY = Vector2(0, 400)

var respawn_position = Vector2(3.0, -2.0)

var in_air_last_frame = false

func _ready() -> void:
	position = respawn_position

func _physics_process(delta: float) -> void:
	if position.y > 140:
		$SpeakerDie.play()
		position = respawn_position
	
	if is_on_floor() && in_air_last_frame:
		$SpeakerLand.play()
	
	# Add the gravity.
	if not is_on_floor():
		in_air_last_frame = true
		velocity += GRAVITY * delta
	else:
		in_air_last_frame = false
		
		

	# Handle jump.
	if Input.is_action_just_pressed("primary") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
		
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
