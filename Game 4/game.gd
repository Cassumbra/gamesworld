extends Node2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var center_tile = Vector2i(Game4Constants.MAP_WIDTH / 2, Game4Constants.MAP_HEIGHT / 2)
	var center = $Collectables.map_to_local(center_tile)
	$Rose.position = center
	$Camera.position = center


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Rose/CanvasLayer/VBoxContainer/RemainingTime.set_value(($TimerTimeRemaining.time_left / $TimerTimeRemaining.wait_time) * 100)


func _on_timer_apple_spawn_timeout() -> void:
	while true:
		var rand_cell = Vector2(rng.randi_range(0, Game4Constants.MAP_WIDTH), rng.randi_range(0, Game4Constants.MAP_HEIGHT))
		if $Collectables.get_cell_source_id(rand_cell) == -1:
			$Collectables.set_cell(rand_cell, 1, Vector2i.ZERO, 0)
			#print($Collectables.get_cell_alternative_tile(rand_cell))
			break
	
	for x in Game2Constants.MAP_WIDTH:
		for y in Game2Constants.MAP_HEIGHT:
			var pos = Vector2i(x, y)
			var source_id = $Collectables.get_cell_source_id(pos)
			if source_id > -1:
				var scene_source = $Collectables.tile_set.get_source(source_id)
				if scene_source is TileSetScenesCollectionSource:
					var alt_id = $Collectables.get_cell_alternative_tile(pos)
					# The assigned PackedScene.
					var packed_scene = scene_source.get_scene_tile_scene(alt_id)
					var scene = packed_scene.instantiate()
					if $Preserved.get_cell_source_id(pos) == -1 && rng.randf_range(0, 1.0) > 0.9:
						if scene.apple_type_decays_into != -1:
							$Collectables.set_cell(pos, 1, Vector2i.ZERO, scene.apple_type_decays_into)
						else:
							$Collectables.erase_cell(pos)
						
					scene.queue_free()


func _on_timer_time_remaining_timeout() -> void:
	get_tree().paused = true
	#process_mode = Node.PROCESS_MODE_DISABLED
