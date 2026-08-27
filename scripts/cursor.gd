class_name Cursor extends Node3D

@onready var camera:= get_parent() as Camera3D

@onready var shadow:= $Shadow

@export_range(1, 1000) var hover_height:float = 2.0
@export_range(-2, 2) var lowered_height:float = -1.5
@export_range(0.0, 1.0) var pickup_time:float = 0.15

# The total time the cursor shakes with no target
@export var shake_tween_time:float = 0.3
@export var shake_tween_distance:float = 0.2

# Did an input have a target
var has_target:bool = false

var held_node:PickupTarget

const RAY_LENGTH = 1000.0

var cursor_position:Vector3

func _ready() -> void:
	global_rotation =  Vector3(0,0,0)
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * RAY_LENGTH
	
	var space_state = get_world_3d().direct_space_state
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var exclude = [self]
	if (held_node != null):
		exclude.append(held_node.get_parent())
	query.exclude = exclude
	var result = space_state.intersect_ray(query)
	
	if result:
		cursor_position = result.position + Vector3(0, hover_height, 0)
		shadow.global_position = result.position
	
	global_position = cursor_position

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var control_type:CursorTarget = CursorTarget.NONE
		if event.button_index == 1:
			control_type = CursorTarget.TROOP
		if event.button_index == 2:
			control_type = CursorTarget.GENERAL
		if event.is_pressed():
			has_target=false
			get_tree().call_group("Interactables", "interact", self, control_type)
			if not has_target:
				shake()
		if event.is_released():
			if has_target:
				drop(held_node)

func pick_up(target:PickupTarget) -> void:
	has_target = true
	held_node = target
	attatch()

func drop(target:PickupTarget) -> void:
	has_target = true
	held_node = target
	detatch()

func attatch() -> void:
	held_node.dragging = true
	held_node.follow_target = $Model

func detatch() -> void:
	held_node.dragging = false
	held_node.follow_target = null
	held_node.on_place(held_node.interact_type)

#func lower(tween:Tween, callback:Callable = do_nothing) -> void:
	#tween.tween_property(Model, "position", Vector3(0,lowered_height,0), pickup_time)
	#tween.tween_callback(callback)

#func raise(tween:Tween, callback:Callable = do_nothing) -> void:
	#tween.tween_property($Model, "position", Vector3(0,0,0), pickup_time)
	#tween.tween_callback(callback)

func do_nothing(_args) -> void:
	pass

func shake() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property($Model, "position", Vector3(shake_tween_distance,0,0), shake_tween_time/3)
	tween.tween_property($Model, "position", Vector3(-shake_tween_distance,0,0), shake_tween_time/3)
	tween.tween_property($Model, "position", Vector3(0,0,0), shake_tween_time/3)

enum CursorTarget{
	NONE,
	TROOP,
	GENERAL,
}
