extends Node

#export var object_name = "NULL"
#
#export(String, "None", "Talk", "Interact") var interact_type = "None"
#
#export(Array, String, MULTILINE) var interact_text = ["TEXT NO LOAD SORRY I ERROR TRY A FURTHER"]
#
#export(String, "Random", "Ordered") var text_order = "Ordered"

##Any index within the interact_text array
#var text_pointer = 0
#
#export(Array, Texture) var sprites
#
#export(Array, AudioStream) var voices
#
@export var snap_to_ground = true

#var voice_index = 0

#@onready var sprite = $Sprite3D
#@onready var voice = $Voice

@onready var world

var player
var player_pos

signal interact(interactor)
signal send_object(bind)

#Define variables for corruption mechanics here:


#End of defining corruption mechanic variables.
@export_enum("Y-Billboard", "Y-Billboard Flip", "Billboard", "Flat", "Spin") var rotation_type: String

@export var flip_h: bool

func _ready():
	#sprites[0] = texture
	#sprite.texture = sprites[randi() % sprites.size()]
	#voice.stream = voices[randi() % voices.size()]
	
	#if snap_to_ground:
	#	move_and_slide_with_snap(Vector3(0, 0, 0), Vector3.DOWN, Vector3.UP)
	
	
	#Make sure to also update world whenever world scene is changed!!
	#world = get_node("..")
	world = get_owner()
	send_object.connect(_on_Object_send_object.bind(world))
	#connect("send_object", world, "_on_Object_send_object")
	emit_signal("send_object", self)

	
func _process(delta):
	if rotation_type == "Y-Billboard":
		billboard()
		sprite.rotation_degrees.z = 0
		sprite.rotation_degrees.x = 0
	elif rotation_type == "Y-Billboard Flip":
		billboard(true)
		sprite.rotation_degrees.z = 0
		sprite.rotation_degrees.x = 0
	elif rotation_type == "Billboard":
		billboard()
	elif rotation_type == "Spin":
		sprite.rotation_degrees.x += 20 * delta
		
func billboard(flip = false):
	player_pos = player.get_node("Body").get_global_transform().origin
	sprite.look_at(player_pos, Vector3.UP)
	if flip:
		if sprite.rotation_degrees.y > -90 and sprite.rotation_degrees.y < 90:
			sprite.flip_h = not flip_h
		else:
			sprite.flip_h = flip_h

#func play_sample():
	#var player = voice.duplicate()
	#add_child(player)
	#player.play()
	#await player.finished
	#player.queue_free()
	
#func interact(interactor):
	#play_sample()
	#emit_signal("interact", interactor)

func _on_World_send_player(p):
	player = p
	
