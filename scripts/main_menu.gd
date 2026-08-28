class_name MainMenu extends Node

@onready var quit_BTN : InteractNode =  $Quit
@onready var play_BTN : InteractNode =  $Play

@export_file_path(".tscn") var game_scene_path = "res://scenes/game.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quit_BTN.on_node_clicked.connect(quit)
	play_BTN.on_node_clicked.connect(load_game)

func load_game():
	Global.goto_scene(game_scene_path)

func quit():
	print("Quitting")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
