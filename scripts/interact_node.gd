class_name InteractNode extends Node3D

var hover_target:bool = false

@export var un_color = Color("#000000")
@export var hover_color = Color("c4601dff")

signal on_node_clicked

@onready var mesh:MeshInstance3D = $MeshInstance3D

func _hover() -> void:
	mesh.get_active_material(0).set("albedo_color", hover_color)
	hover_target = true

func _hover_end() -> void:
	mesh.get_active_material(0).set("albedo_color", un_color)
	hover_target = false

func _input(event: InputEvent) -> void:
	if not hover_target: return
	if event is InputEventMouseButton and event.button_index == 1:
		on_node_clicked.emit()
