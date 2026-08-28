class_name MainMenu extends Node

@export_file_path(".tscn") var game_scene_path = "res://scenes/game.tscn"

func load_game():
	Global.goto_scene(game_scene_path)

func quit():
	print("Quitting")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
