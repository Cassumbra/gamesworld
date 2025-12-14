extends Node2D

enum AppleType {
	RED,
	FERMENTED,
	BAD,
	BLUE,
}

@export var apple_type: AppleType
@export var apple_type_decays_into: int
@export var apple_type_enhances_into: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
