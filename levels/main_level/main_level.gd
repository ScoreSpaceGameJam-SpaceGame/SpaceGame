extends Node2D

const SCROLL_SPEED: float = .5
const NEW_PLATFORM_OFFSET: int = 40 # The ammount to subtract from the deleted cell to get the new Y location. Positive for up and negative for down
const LEFT_SPAWN_LIMIT: int = -1
const RIGHT_SPAWN_LIMIT: int = 80
const MIN_PLATFORM_SPACING: int = 5

var last_x_spawn_location : int = 0

@onready var audio_stream : AudioStreamPlayer = $AudioStreamPlayer

var tile_map_layers: Array = []

func _ready() -> void:
	audio_stream.finished.connect(restart_music)
	tile_map_layers.push_back($InitialTileMapLayer)

func restart_music() -> void:
	audio_stream.play()

func _physics_process(delta: float) -> void:
	for tilemap in tile_map_layers:
		tilemap.translate(Vector2.DOWN * SCROLL_SPEED)
	

func _on_death_body_entered(body: Node2D) -> void:
	if "Player" in body.get_groups():
		print_debug("Player will have died here")
		
	if body is TileMapLayer:
		tile_map_layers.pop_at(tile_map_layers.find(body))
		body.queue_free()

func generate_new_tile_map_layer() -> void:
	pass
