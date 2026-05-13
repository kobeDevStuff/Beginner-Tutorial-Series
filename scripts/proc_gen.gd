# Extends Godot's built-in TileMap to handle procedural terrain generation
extends TileMap
class_name ProceduralTerrain

## Author: Kobe Della Favory
## Updated: 13/05/26


# Noise generators used to determine biomes and elevation
var moisture: FastNoiseLite = FastNoiseLite.new()
var temperature: FastNoiseLite = FastNoiseLite.new()
var altitude: FastNoiseLite = FastNoiseLite.new()

# Dimensions of a single terrain chunk in tiles
var width: int = 64
var height: int = 64

# Keeps track of which chunk center coordinates have already been generated
var loaded_chunks: Dictionary

# Reference to the player character to track position for chunk generation/unloading
@onready var character_body_2d: CharacterBody2D = $"../CharacterBody2D"

func _ready() -> void:
	# Randomize the seeds for all noise generators to ensure unique terrain per run
	moisture.seed = randi()
	temperature.seed = randi()
	altitude.seed = randi()
	
	# Lower frequency makes the altitude changes more gradual (smoother hills/valleys)
	altitude.frequency = 0.01

func _process(_delta: float) -> void:
	# Convert the player's global pixel position to TileMap grid coordinates
	var player_tile_pos: Vector2i = local_to_map(character_body_2d.position)
	
	# Continuously attempt to generate terrain around the player and clean up old chunks
	generate_chunk(player_tile_pos)
	unload_distant_chunks(player_tile_pos)

# Helper function to calculate the Euclidean distance between two points
func get_dist(p1: Vector2, p2: Vector2) -> float:
	var resultant: Vector2 = Vector2(p2 - p1)
	return resultant.length()

func generate_chunk(pos: Vector2i) -> void:
	# Skip generation if this chunk has already been loaded
	if loaded_chunks.has(pos):
		return
	
	# Mark this position as loaded to prevent duplicate generation
	loaded_chunks[pos] = true
	
	# Iterate through a local grid to place tiles for the current chunk
	for x in range(width):
		for y in range(height):
			# Calculate the absolute tile coordinates relative to the chunk's center position
			var tile_x: int = pos.x - int(width / 2.0) + x
			var tile_y: int = pos.y - int(height / 2.0) + y
			
			# Sample noise at the specific absolute tile coordinates
			var moist_noise: float = moisture.get_noise_2d(tile_x, tile_y)
			var temp_noise: float = temperature.get_noise_2d(tile_x, tile_y)
			var alt_noise: float = altitude.get_noise_2d(tile_x, tile_y)
			
			# Normalize moisture and temperature noise from the default [-1.0, 1.0] range to [0.0, 1.0]
			var norm_moist: float = (moist_noise + 1.0) / 2.0
			var norm_temp: float = (temp_noise + 1.0) / 2.0
			
			# Map the normalized noise values to an atlas coordinate grid (0 to 3)
			# floori() rounds down to an integer, clampi() ensures it stays safely within bounds
			var atlas_x: int = clampi(floori(norm_moist * 3), 0, 3)
			var atlas_y: int = clampi(floori(norm_temp * 3), 0, 3)
			
			var atlas_coords: Vector2i
			
			# Determine final atlas coordinates based on altitude 
			if alt_noise < 0.0:
				# If altitude is below 0, override the biome logic to place water tiles
				# (Assuming x=3 in your tileset atlas represents a column of water tiles)
				atlas_coords = Vector2i(3, atlas_y)
			else:
				# Otherwise, use the calculated land biome based on moisture and temperature
				atlas_coords = Vector2i(atlas_x, atlas_y)
			
			# Place the tile on layer 0 at the calculated coordinates using the determined atlas tile
			set_cell(0, Vector2i(tile_x, tile_y), 0, atlas_coords)

func clear_chunk(pos: Vector2i) -> void:
	# Iterate through the exact same local grid used for generation to target the right tiles
	for x in range(width):
		for y in range(height):
			var tile_x: int = pos.x - int(width / 2.0) + x
			var tile_y: int = pos.y - int(height / 2.0) + y
			
			# Erase the tile at the specified coordinates on layer 0
			erase_cell(0, Vector2i(tile_x, tile_y))

func unload_distant_chunks(player_pos: Vector2i) -> void:
	# Define how far a chunk can be before it is unloaded (roughly 2 chunk widths away)
	var unload_distance_threshold: float = (width * 2) + 1.0
	
	# Get a static list of currently loaded chunks to safely iterate over 
	# while potentially modifying the dictionary inside the loop
	var chunks_to_check: Array = loaded_chunks.keys()
	
	for chunk: Vector2i in chunks_to_check:
		var distance_to_player: float = get_dist(chunk, player_pos)
		
		# If the chunk is outside the threshold, clear its visual tiles and stop tracking it
		if distance_to_player > unload_distance_threshold:
			clear_chunk(chunk)
			loaded_chunks.erase(chunk)