extends Node2D

const SCROLL_SPEED: float = 1
const TILE_MAP_LAYER_WIDTH = 90
const TILE_MAP_LAYER_HEIGHT = 50
const MIN_NUMBER_OF_PLATFORMS_PER_LAYER = 20
const MAX_NUMBER_OF_PLATFORMS_PER_LAYER = 40
const MIN_WIDTH_OF_PLATFORM = 3
const MAX_WIDTH_OF_PLATFORM = 7
const WIDTH_OF_TILESET = 2
const HEIGHT_OF_TILESET = 2
const TILE_SET_TO_USE = "res://levels/main_level/map_tileset.tres"

@onready var audio_stream : AudioStreamPlayer = $AudioStreamPlayer

var score = 0
var tile_map_layers: Array = []

func _ready() -> void:
	audio_stream.finished.connect(restart_music)
	tile_map_layers.push_back($InitialTileMapLayer)
	generate_new_tile_map_layer()
	Global.current_score = 0

func restart_music() -> void:
	audio_stream.play()

func _physics_process(delta: float) -> void:
	for tilemap in tile_map_layers:
		tilemap.translate(Vector2.DOWN * SCROLL_SPEED)

func _on_tile_map_death_body_entered(body: Node2D) -> void:
	if body is not TileMapLayer:
		return

	tile_map_layers.pop_at(tile_map_layers.find(body))
	body.queue_free()
	generate_new_tile_map_layer()

func generate_new_tile_map_layer() -> void:
	# Instantiate the variables we will need
	var number_of_platforms_to_make = RandomNumberGenerator.new().randi_range(MIN_NUMBER_OF_PLATFORMS_PER_LAYER, MAX_NUMBER_OF_PLATFORMS_PER_LAYER)
	var new_tile_map_layer = TileMapLayer.new()
	new_tile_map_layer.tile_set = load(TILE_SET_TO_USE)
	new_tile_map_layer.use_kinematic_bodies = true
	
	# Loop through the number of platforms that we are making to generate the tilemap
	for i in range(number_of_platforms_to_make):
		var starting_location = Vector2i(
			RandomNumberGenerator.new().randi_range(0, TILE_MAP_LAYER_WIDTH),
			RandomNumberGenerator.new().randi_range(0, TILE_MAP_LAYER_HEIGHT)
		)
		var this_platform_width = RandomNumberGenerator.new().randi_range(MIN_WIDTH_OF_PLATFORM, MAX_WIDTH_OF_PLATFORM)
		
		for j in range(this_platform_width):
			if starting_location.x + j >= TILE_MAP_LAYER_WIDTH:
				break
			new_tile_map_layer.set_cell(
				Vector2i(starting_location.x + j, starting_location.y), 
				0, 
				Vector2i(RandomNumberGenerator.new().randi_range(0, WIDTH_OF_TILESET - 1), RandomNumberGenerator.new().randi_range(0, WIDTH_OF_TILESET -1))
			)
	new_tile_map_layer.position = Vector2(0, -800)
	$".".add_child(new_tile_map_layer)
	tile_map_layers.push_back(new_tile_map_layer)

func _on_update_score() -> void:
	Global.current_score += 1
	$CanvasLayer/Score.text = str(Global.current_score)
	$ScoreTimer.start()


func _on_player_death_body_entered(body: Node2D) -> void:
	if "Player" not in body.get_groups():
		return
	$ScoreTimer.stop()
	Global.game_over()
