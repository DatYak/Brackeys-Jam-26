class_name MainMenu extends Node

@onready var quit_BTN : InteractNode =  $Quit
@onready var play_BTN : InteractNode =  $Play

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	quit_BTN.on_node_clicked.connect(quit)


func load_game():
	pass

func quit():
	print("Quitting")
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()
