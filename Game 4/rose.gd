extends CharacterBody2D


@export var display_inebrobar: ProgressBar
@export var display_score: Label
@export var display_multiplier: Label

# TODO: Can we use signals for this? Don't worry about it for this project,
# 		but I feel like using exports for this may be bad practice.
#		just writing a note for myself so that I consider it in the future.
@export var collectables: TileMapLayer
@export var preserved: TileMapLayer

const SPEED = 60.0

var score = 0
var multiplier = 1

func _ready() -> void:
	$AnimatedSprite2D.play()
	display_score.set_text(format(score))
	display_multiplier.set_text(format(multiplier))

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var horizontal := Input.get_axis("left", "right")
	if !$TimerInebriation.is_stopped():
		horizontal *= -1
	if horizontal:
		velocity.x = horizontal * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	var vertical := Input.get_axis("up", "down")
	if !$TimerInebriation.is_stopped():
		vertical *= -1
	if vertical:
		velocity.y = vertical * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
		

	
	if horizontal != 0:
		$Reticle.position = Vector2(horizontal, 0) * 12
	elif vertical != 0:
		$Reticle.position = Vector2(0, vertical) * 12
	
	if velocity != Vector2.ZERO:
		$AnimatedSprite2D.play("walking")
		if $TimerStep.is_stopped():
			$SpeakerStep.play()
			$TimerStep.start()
	else:
		$AnimatedSprite2D.play("default")
		
	if velocity.x < 0:
		$AnimatedSprite2D.flip_h = true
	elif velocity.x > 0:
		$AnimatedSprite2D.flip_h = false

	move_and_slide()
	
	if Input.is_action_just_pressed("primary"):
		for area in $Reticle.get_overlapping_areas():
			if "apple_type" in area:
				area.queue_free()
				var map_pos = collectables.local_to_map(area.position)
				collectables.set_cell(map_pos, 1, Vector2i.ZERO, area.apple_type_enhances_into)
				preserved.erase_cell(map_pos)
				$SpeakerEnhance.play()
		
	if Input.is_action_just_pressed("secondary"):
		for area in $Reticle.get_overlapping_areas():
			if "apple_type" in area:
				var map_pos = collectables.local_to_map(area.position)
				preserved.set_cell(map_pos, 0, Vector2i(10, 4)) 
				$SpeakerPreserve.play()
				
	display_inebrobar.set_value(($TimerInebriation.time_left / $TimerInebriation.wait_time) * 100)


func _on_timer_inebriation_timeout() -> void:
	multiplier = 1
	display_multiplier.set_text(format(multiplier))

func _on_area_entered(area: Area2D) -> void:
	if "apple_type" in area:
		#print(area.apple_type)
		var map_pos = collectables.local_to_map(area.position)
		area.queue_free()
		preserved.erase_cell(map_pos)
		$SpeakerEat.play()
		match area.apple_type:
			area.AppleType.RED:
				score += 1 * multiplier
			area.AppleType.FERMENTED:
				multiplier *= 2
				$TimerInebriation.start()
			area.AppleType.BAD:
				score += -1 * multiplier
			area.AppleType.BLUE:
				score += 10 * multiplier
		display_score.set_text(format(score))
		display_multiplier.set_text(format(multiplier))
		
# From deleted r/godot user
func format(n):
	n = str(n)
	var size = n.length()
	var s = ""
	
	for i in range(size):
			if((size - i) % 3 == 0 and i > 0):
				s = str(s,",", n[i])
			else:
				s = str(s,n[i])
			
	return s
