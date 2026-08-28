extends Node

var current_scene = null

# With help from:
# https://docs.godotengine.org/en/stable/tutorials/scripting/singletons_autoload.html

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var root = get_tree().root
	# Get the last child of root
	current_scene = root.get_child(-1)

func goto_scene(path):
	_deferred_goto_scene.call_deferred(path)


func _deferred_goto_scene(path):
	# It is now safe to remove the current scene.
	current_scene.free()

	# Load the new scene.
	var s = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = s.instantiate()

	# Add it to the active scene, as child of root.
	get_tree().root.add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene_to_file() API.
	get_tree().current_scene = current_scene
