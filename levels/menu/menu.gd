extends Control


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/main_level/main_level.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_reset_score_pressed() -> void:
	pass # Replace with function body.
