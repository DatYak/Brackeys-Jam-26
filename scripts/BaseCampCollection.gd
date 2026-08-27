class_name BaseCampCollection extends Node

var contents : Array[BaseCamp]

func _ready() -> void:
	for node in get_children():
		if node is BaseCamp:
			contents.append(node as BaseCamp)
