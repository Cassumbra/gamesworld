extends CharacterBody2D

@export var foreground: TileMapLayer
@export var backwalls: TileMapLayer

@export var label_score: Label
@export var label_held_value: Label


const SPEED = 60.0
const JUMP_VELOCITY = -150.0
const GRAVITY = Vector2(0, 400)

var in_air_last_frame = false
var is_dead = false

var held_value = 0
var score = 0

func _ready() -> void:
	$Camera.limit_left = 0
	$Camera.limit_right = Game2Constants.MAP_WIDTH * 8
	$Camera.limit_top = -4 * 8
	$Camera.limit_bottom = Game2Constants.MAP_HEIGHT * 8

func _physics_process(delta: float) -> void:
	
	if is_dead:
		return
	
	if foreground.local_to_map(position).y <= 0:
		score += held_value
		held_value = 0
		label_score.set_text(str(score))
		label_held_value.set_text(str(held_value))
	
	if Input.is_action_pressed("secondary") && $TimerDig.is_stopped():
		$TimerDig.start()
		var dig_position_1 = foreground.local_to_map(position)
		var dig_position_2 = foreground.local_to_map(position)
		
		var horizontal := Input.get_axis("left", "right")
		var vertical := Input.get_axis("up", "down")
		
		if horizontal:
			dig_position_1.x += horizontal
			if vertical == -1:
				dig_position_2.y += vertical
			elif vertical == 1:
				dig_position_2.x += horizontal
		if vertical:
			dig_position_1.y += vertical
		
		var break_list = [dig_position_1, dig_position_2]
		
		for position in break_list:
			var data = foreground.get_cell_tile_data(position)
			if data:
				if data.get_custom_data("Breakable"):
					foreground.erase_cell(position)
					held_value += data.get_custom_data("Value")
					label_held_value.set_text(str(held_value))
					if data.get_custom_data("Breaks Into") != Vector2i(-1, -1):
						backwalls.set_cell(position, 0, data.get_custom_data("Breaks Into"))
		
	
	if position.y > Game2Constants.MAP_HEIGHT * 8:
		$SpeakerDie.play()
		$AnimatedSprite2D.hide()
		is_dead = true
		
		#position = Vector2(.0, -3.0)
	
	if is_on_floor() && in_air_last_frame:
		$SpeakerLand.play()
	
	# Add the gravity.
	if not is_on_floor():
		in_air_last_frame = true
		velocity += GRAVITY * delta
	else:
		in_air_last_frame = false
		
		

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
		#$AnimatedSprite2D.set_frame_and_progress(0, 0.0)
	
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false
	

	move_and_slide()
	
	if $Area.overlaps_body(foreground):
		var collided_tile = foreground.local_to_map(position)
		var data = foreground.get_cell_tile_data(collided_tile)
		
		if data:
			if data.get_custom_data("Lava"):
				# TODO: Copied code! bad practice
				#		Best would be to send a signal, I believe. Too bad!
				$SpeakerDie.play()
				$AnimatedSprite2D.hide()
				is_dead = true
			elif data.get_custom_data("Climbable"):
				Global.todo()
				
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		#var collided_tile = foreground.local_to_map(collision.get_position()) #+ -Vector2i(collision.get_normal())
		#var data = foreground.get_cell_tile_data(collided_tile)
		
		#step up
		if collision.get_normal().x != 0 \
		&& foreground.get_cell_source_id(foreground.local_to_map(position) + Vector2i(0, -1)) \
		&& foreground.get_cell_source_id(foreground.local_to_map(position) + Vector2i(-collision.get_normal().x, -1)) \
		&& is_on_floor() && Input.is_action_pressed("up"):
			position += Vector2(-collision.get_normal().x * 0.1, -8)
			#print("beep!")
