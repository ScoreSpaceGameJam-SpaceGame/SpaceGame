extends Node

var current_score

func game_over():
	if get_high_score() < current_score:
		save_score(current_score)
	
	get_tree().change_scene_to_file("res://levels/menu/menu.tscn")

func save_score(score: int) -> void:
	var save_file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	save_file.store_var(score)

func get_high_score() -> int:
	var save_file = FileAccess.open("user://highscore.save", FileAccess.READ)
	return int(save_file.get_var())
	
