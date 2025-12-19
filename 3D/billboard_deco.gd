extends Sprite3D

@export_enum("Y-Billboard", "Y-Billboard Flip", "Billboard", "Flat", "Spin") var rotation_type: String

#@export var flip_horizontal: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if rotation_type == "Y-Billboard":
		billboard()
		rotation_degrees.z = 0
		rotation_degrees.x = 0
	elif rotation_type == "Y-Billboard Flip":
		billboard(true)
		rotation_degrees.z = 0
		rotation_degrees.x = 0
	elif rotation_type == "Billboard":
		billboard()
	elif rotation_type == "Spin":
		rotation_degrees.x += 20 * delta
		
func billboard(flip = false):
	
	look_at(Global3d.player_pos, Vector3.UP)
	if flip:
		if rotation_degrees.y > -90 and rotation_degrees.y < 90:
			flip_h = not flip_h
		else:
			flip_h = flip_h
