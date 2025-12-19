extends Node3D

const WAIT_TIME = 0.01
var wait_time = WAIT_TIME

var cast_dist = 1.5
var offset = 0.01
var direction = Vector3(0, 0, 0)

signal can_step()

@onready var head_check = $HeadCheck
@onready var body_check = $BodyCheck
@onready var feet_check = $FeetCheck

@export var TargetPath: NodePath

@onready var TargetNode = get_node(TargetPath)
@onready var StartOffset = self.transform.origin - TargetNode.transform.origin

var collider
var collider_shape
var collider_points
var nearest_point

func _physics_process(delta):
	self.transform.origin = TargetNode.transform.origin + StartOffset
	
	#These got changed from cast_to to target_position. not sure if this will work
	head_check.target_position = Vector3(direction.x*cast_dist, 0, direction.z*cast_dist)
	body_check.target_position = Vector3(direction.x*cast_dist, 0, direction.z*cast_dist)
	feet_check.target_position = Vector3(direction.x*cast_dist, 0, direction.z*cast_dist)
	
	if not head_check.is_colliding() and not body_check.is_colliding() and feet_check.is_colliding():
		wait_time -= delta
		if wait_time < 0:
			emit_signal("can_step")
			wait_time = WAIT_TIME
	

func _on_Player_direction_changed(d):
	direction = d

func _on_Body_send_height(height):
	head_check.position.y = height
	body_check.position.y = -height + height/1.5 + 0.1
	feet_check.position.y = -height + 0.1
