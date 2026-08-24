extends Node3D

@onready var camera:= get_parent() as Camera3D
@export_range(1, 1000) var hover_height:float = 2.0
@export_range(1, 1000) var lowered_height:float = -1.5

const RAY_LENGTH = 1000.0

var cursor_position:Vector3

func _ready() -> void:
	global_rotation =  Vector3(0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if result:
		cursor_position = result.position + Vector3(0, hover_height, 0)
	
	global_position = cursor_position

func _lower() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Model, "position", Vector3(0,0,0), 0.25)
