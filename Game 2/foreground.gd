extends TileMapLayer

var rng = RandomNumberGenerator.new()
var cardinal_offsets = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1), ]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for x in Game2Constants.MAP_WIDTH:
		for y in Game2Constants.MAP_HEIGHT:
			set_cell(Vector2(x, y), 0, Vector2(0, 2))
			if y > 5 && rng.randf_range(0.0, 1.0) > 0.9: # * ((y/float(Game2Constants.MAP_HEIGHT)) + 1)
				set_cell(Vector2(x, y), 0, Vector2(0, 5))
			if y > 10 && rng.randf_range(0.0, 1.0) > 0.99:
				set_cell(Vector2(x, y), 0, Vector2(5, 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $Timer.is_stopped():
		$Timer.start()
		var just_placed = []
		
		for x in Game2Constants.MAP_WIDTH:
			for y in Game2Constants.MAP_HEIGHT:
				var pos = Vector2i(x, y)
				var data = get_cell_tile_data(pos)
				if just_placed.has(pos):
					continue
				
				if data:
					if data.get_custom_data("Lava"):
						var lava = get_cell_atlas_coords(pos)
						for offset in cardinal_offsets:
							var adj = pos + offset
							
							# Air. Don't spread up.
							if get_cell_source_id(adj) == -1 && offset.y != -1:
								set_cell(adj, 0, lava)
								just_placed.push_back(adj)
							# Dirt. Random chance.
							elif rng.randf_range(0.0, 1.0) > 0.975 :
								set_cell(adj, 0, lava)
								just_placed.push_back(adj)
