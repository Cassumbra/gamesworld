extends Control

onready var crosshair = $CenterContainer/Crosshair
onready var message = $MessagePanel/Message
onready var fps = $FpsPanel/Fps
onready var animation_player = $AnimationPlayer
onready var color_rect = $ColorRect

onready var transition = $Transition
onready var click = $Transition/Click1
onready var transition_timer = $Transition/Timer

var player
var line_number = 0
var line_count


var texture_none = load("res://ui/none.png")
var texture_interact = load("res://ui/interact.png")
var talk = load("res://ui/talk.png")

#func _ready():
#	randomize()

func _process(_delta):
	fps.set_text("FPS: " + str(Engine.get_frames_per_second()))

func _on_Player_look_object(object, interact):
	#Change crosshair
	if object.interact_type == "None":
		crosshair.texture = texture_none
	elif object.interact_type == "Interact":
		crosshair.texture = texture_interact
	elif object.interact_type == "Talk":
		crosshair.texture = talk
	#Do interactions if possible
	if interact and object.interact_type != "None":
		#print(str(player))
		object.interact(player)
		if object.text_order == "Random":
			message.text = object.object_name + " SAYS:" + object.interact_text[randi() % object.interact_text.size()]
		elif object.text_order == "Ordered":
			message.text = object.object_name + " SAYS: " + object.interact_text[object.text_pointer]
			object.text_pointer += 1
			if object.text_pointer > object.interact_text.size() - 1:
				object.text_pointer = 0

func _on_Player_tree_entered():
	player = get_parent()
	
func scene_transition():
	transition.show()
	click.play()
	transition_timer.start(0.33)

func _on_Player_scroll(direction):
	if direction == "down":
		line_number += 1
		if line_number > message.get_line_count() - 1:
			line_number = message.get_line_count() - 1
	elif direction == "up":
		line_number-= 1
		if line_number < 0:
			line_number = 0
	elif direction == "reset":
		line_number = 0
		
	message.scroll_to_line(line_number)

func _on_Timer_timeout():
	click.play()
	transition.hide()
	message.text = "Welcome to the next area!"
