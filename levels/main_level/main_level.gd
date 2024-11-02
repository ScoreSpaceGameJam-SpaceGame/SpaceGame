extends Node2D

const scroll_speed = 1

@onready var tilemap : TileMapLayer = $TileMapLayer
@onready var camera : Camera2D = $Camera2D
@onready var death_area : Area2D = $Death
@onready var audio_stream : AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	audio_stream.finished.connect(restart_music)

func restart_music() -> void:
	audio_stream.play()

func _physics_process(delta: float) -> void:
	camera.translate(Vector2.UP)
	death_area.translate(Vector2.UP)

func _on_death_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		handle_tile_death()

func find_bottom_most_tile() -> Vector2i:
	# Define the variables
	var tileset := tilemap.get_used_cells()
	var bottom_cell := tileset[0]
	
	# The map moves up and the bottom most would be the maximum y value
	# We iterate and compare since Vector2i compares x first not y
	for i in range(tileset.size() - 1):
		if tileset[i + 1].y > bottom_cell.y:
			bottom_cell = tileset[i+1]
	return bottom_cell

func handle_tile_death():	
	# We need to get all the coordinates of the platform
	# This will call recursive method to get all used cells connected to the
	# First on in the array of the used cells, which should be the left
	# Most cell aka the one that triggered this method
	var deletion_array = []
	var bottom_cell = find_bottom_most_tile()
	var blah = tilemap.get_used_cells()
	create_deletion_array(bottom_cell, deletion_array)
	
	# Delete each cell and update the internals for the tilemap
	for c in deletion_array:
		tilemap.erase_cell(c)
	tilemap.update_internals()


# Arrays are pass by reference, so we are continuously passing the same array
# for this method to add each cell to it
func create_deletion_array(cell: Vector2i, set_for_deletion: Array) -> void:
	# Add this cell to the array, marking it for deletion and preventing stack overflows
	# DANGER This functionality should only be here, if you move it else where it could
	# Cause this method to not have an escape clause
	set_for_deletion.push_back(cell)
	
	# Get the down and right cells
	var right = tilemap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_RIGHT_SIDE)
	var left = tilemap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_LEFT_SIDE)
	var up = tilemap.get_neighbor_cell(cell, TileSet.CELL_NEIGHBOR_TOP_SIDE)
	
	# Check if they are in the used cells
	# If they have not been marked for deletion yet then we call this method
	# with the cell so we can mark it at the beginning, otherwise we do nothing
	# effectively escaping the method
	if right in tilemap.get_used_cells() and right not in set_for_deletion:
		create_deletion_array(right, set_for_deletion)
	if left in tilemap.get_used_cells() and left not in set_for_deletion:
		create_deletion_array(left, set_for_deletion)
	if up in tilemap.get_used_cells() and up not in set_for_deletion:
		create_deletion_array(up, set_for_deletion)
	
