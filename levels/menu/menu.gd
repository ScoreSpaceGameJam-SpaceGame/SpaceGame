extends Control

func _ready() -> void:
	$Label.text = "High Score: %s" % str(Global.get_high_score())

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://levels/main_level/main_level.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_reset_score_pressed() -> void:
	Global.save_score(0)
	$Label.text = "High Score: 0"
