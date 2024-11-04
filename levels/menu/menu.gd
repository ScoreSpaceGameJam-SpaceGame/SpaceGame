extends Control

@onready var score_board = $Score
@onready var audio_streamer : AudioStreamPlayer = $AudioStreamPlayer
@onready var button_sfx : AudioStreamPlayer = $ButtonClick

func _ready() -> void:
	score_board.set_label("High Score: %s" % str(Global.get_high_score()))

func _on_play_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	get_tree().change_scene_to_file("res://levels/main_level/main_level.tscn")

func _on_exit_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	get_tree().quit()

func _on_reset_score_pressed() -> void:
	Global.save_score(0)
	Global.high_score = 0
	score_board.set_label("High Score: 0")
	button_sfx.play()

func _on_audio_stream_player_finished() -> void:
	audio_streamer.play()
