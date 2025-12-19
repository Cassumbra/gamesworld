extends Node2D

@onready var camera: Camera2D = $Player/Camera2D
@onready var background: TextureRect = $Background

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera.limit_left = background.position.x
	camera.limit_right = background.size.x + background.position.x
	camera.limit_top = background.position.y
	camera.limit_bottom = background.size.y + background.position.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
