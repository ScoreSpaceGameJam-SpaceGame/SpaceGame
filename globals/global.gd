extends Node

const SCROLL_SPEED: float = 1.5

var current_score: int
var high_score: int

func game_over():
	if get_high_score() < current_score:
		high_score = current_score
		save_score(current_score)
	
func save_score(score: int) -> void:
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	save_file.store_var(score)

## Get's the high score from file system and sets the variable in global
## Returns the high score so you can set local variables
func get_high_score() -> int:
	var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
	
	if not save_file:
		high_score = 0
		return 0
	
	high_score = int(save_file.get_var())
	return high_score
	
