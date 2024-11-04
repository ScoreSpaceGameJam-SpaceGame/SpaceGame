extends Node2D

const SCROLL_SPEED: float = 0
const TILE_MAP_LAYER_WIDTH = 90
const TILE_MAP_LAYER_HEIGHT = 50
const MIN_NUMBER_OF_PLATFORMS_PER_LAYER = 20
const MAX_NUMBER_OF_PLATFORMS_PER_LAYER = 40
const MIN_WIDTH_OF_PLATFORM = 3
const MAX_WIDTH_OF_PLATFORM = 7
const WIDTH_OF_TILESET = 5
const HEIGHT_OF_TILESET = 1
const TILE_SET_TO_USE = "res://levels/main_level/map_tileset.tres"

@onready var audio_stream : AudioStreamPlayer = $AudioStreamPlayer

const main_song_loop = preload("res://levels/main_level/inevitable_force_loop.wav")

var score = 0
var tile_map_layers: Array = []

func _ready() -> void:
	audio_stream.finished.connect(restart_music)
	tile_map_layers.push_back($InitialTileMapLayer)
	generate_new_tile_map_layer()
	Global.current_score = 0
	
	if not Global.high_score:
		Global.get_high_score()

func restart_music() -> void:
	audio_stream.stream = main_song_loop
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
				Vector2i(RandomNumberGenerator.new().randi_range(0, WIDTH_OF_TILESET - 1), RandomNumberGenerator.new().randi_range(0, HEIGHT_OF_TILESET -1))
			)
	new_tile_map_layer.position = Vector2(0, -800)
	$".".add_child(new_tile_map_layer)
	tile_map_layers.push_back(new_tile_map_layer)

func _on_update_score() -> void:
	Global.current_score += 1
	$CanvasLayer/Control/ProgressBar/Score.text = "Score: %s" % str(Global.current_score)
	$CanvasLayer/Control/ProgressBar.value = clamp(float(Global.current_score) / float(Global.high_score), 0, 1)
	
	$ScoreTimer.start()

func _on_spawn_astroid() -> void:
	var new_astroid = load("res://levels/main_level/Astroid.tscn").instantiate()
	$CanvasLayer/ParallaxBackground.add_child(new_astroid)
	
	$AstroidSpawnTimer.wait_time = RandomNumberGenerator.new().randf_range(0, 2)
	$AstroidSpawnTimer.start()


func _on_player_death_body_entered(body: Node2D) -> void:
	if "Player" not in body.get_groups():
		return
	
	# Stop everything and end the game
	$Player.queue_free()
	$ScoreTimer.stop()
	Global.game_over()
	$CanvasLayer/Menu/MarginContainer/FinalScore.text = "You had a final score of: %s" % str(Global.current_score)
	
	# Fade the current song loop out and the ending in
	$SongEndingPlayer.play()
	var loop_tween = get_tree().create_tween()
	var ending_tween = get_tree().create_tween()
	loop_tween.tween_property($AudioStreamPlayer, "volume_db", -50, 3)
	ending_tween.tween_property($SongEndingPlayer, "volume_db", 0, 3)
	
	# Open the death menu
	$CanvasLayer/Menu.scale = Vector2(0, 0)
	$CanvasLayer/Menu.visible = true
	var menu_tween = get_tree().create_tween()
	menu_tween.set_trans(Tween.TRANS_EXPO)
	menu_tween.tween_property($CanvasLayer/Menu, "scale", Vector2(1, 1), 2)


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_main_menu_pressed() -> void:
	call_deferred("load_main_menu")

func load_main_menu():
	get_tree().change_scene_to_file("res://levels/menu/menu.tscn")

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()
