class_name PickupTarget extends Node3D

@export var interact_type:Cursor.CursorTarget

## Minimum distance this entity can be from another. [br]
## Used to prevent overlaps.
@export var clearance:float = 1

## Alters the pickup behaviour so that an indicator of the target is moved
## instead of the actual node.
@export var is_moved_as_indicator:bool = false
@onready var parent:Node = self.get_parent().get_parent().get_parent()
@onready var ui:UnitUI = $"../../CharacterStats/UnitInspectUi"
@onready var indicator:Node3D = $Indicator
@onready var mesh:MeshInstance3D = $Mesh

var hover_target:bool = false
var dragging:bool= false
## What dragged_element will move to follow (typically the cursor)
var follow_target:Node3D
## what is actually moved by the cursor
var dragged_element:Node3D

## Where the entity started, and where to return to for the start
## of next turn.
var first_position:Vector3

## Where the entity was last, and where to return on a failed drop.
var last_position:Vector3

var collision_height:float = 0

var area3d:Area3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui.visible = false
	if is_moved_as_indicator:
		dragged_element = indicator
		area3d = $Indicator_Area
	else:
		dragged_element =  mesh
		area3d = $Area
		indicator.visible = false

func _input(_event: InputEvent) -> void:
	if not hover_target:
		return
	
	if not interact_type == Cursor.CursorTarget.TROOP:
		return
	
	if Input.is_action_just_pressed("assign_1"):
		assign_to_dropoff(0)
		
	if Input.is_action_just_pressed("assign_2"):
		assign_to_dropoff(1)
		
	if Input.is_action_just_pressed("assign_3"):
		assign_to_dropoff(2)
	
	if Input.is_action_just_pressed("unassign"):
		on_pick_up(interact_type)
		reset_position()
		


func set_initial_position() -> void:
	first_position = dragged_element.global_position

func _hover() -> void:
	# print("Hovering:" + get_parent().get_parent().name)
	hover_target = true
	ui.display()
	ui.visible = true

func _hover_end() -> void:
	hover_target = false
	ui.visible = false

func interact(cursor: Cursor, interact_control:Cursor.CursorTarget) -> void:
	if hover_target:
		if interact_type == interact_control:
				last_position = global_position
				collision_height = area3d.global_position.y
				cursor.pick_up(self)
				on_pick_up(interact_type)

func on_pick_up(interact_control:Cursor.CursorTarget)->void:
	for area in area3d.get_overlapping_areas():
		if area.is_in_group("Dropoff"):
			var dropoff = area.get_parent() as Dropoff
			if dropoff.interact_type == interact_type:
				dropoff._remove_entity(self)
				break;

func on_place(interact_control:Cursor.CursorTarget) -> void:
	var dropped:bool = false
	for area in area3d.get_overlapping_areas():
		if area.is_in_group("Dropoff"):
			var dropoff = area.get_parent() as Dropoff
			if dropoff.interact_type == interact_control:
				dropped = dropoff._drop_entity(self)
				break
	if not dropped:
		# No drop off point found...
		var tween = get_tree().create_tween()
		tween.tween_property(dragged_element, "global_position", last_position, 0.6)
		area3d.global_position = last_position
	
func _process(_delta: float) -> void:
	if dragging and follow_target:
		var target_pos:Vector3 = follow_target.global_position
		dragged_element.global_position = target_pos
		var area_pos = Vector3(target_pos.x, collision_height, target_pos.z)
		area3d.global_position = area_pos

func reset_position() ->void:
	on_pick_up(interact_type)
	var tween = get_tree().create_tween()
	tween.tween_property(dragged_element, "global_position", first_position, 0.6)
	area3d.global_position = first_position

func reset() -> void:
	dragged_element.global_position = last_position
	area3d.global_position = last_position

func assign_to_dropoff(index:int) -> void:
	var general = Game.instance.allGenerals[index]
	on_pick_up(interact_type)
	area3d.global_position = general.movement.global_position11
	var tween = get_tree().create_tween()
	tween.tween_property(dragged_element, "global_position", general.movement.global_position, 0.6)
	tween.tween_callback(on_place.bind(interact_type))
