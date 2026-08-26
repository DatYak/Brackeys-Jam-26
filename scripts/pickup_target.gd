class_name PickupTarget extends Node3D

@export var interact_type:Cursor.CursorTarget

## Alters the pickup behaviour so that an indicator of the target is moved
## instead of the actual node.
@export var is_moved_as_indicator:bool = false
@onready var parent:Node = self.get_parent().get_parent().get_parent()
@onready var ui:UnitUI = $"../../CharacterStats/UnitInspectUi"
@onready var indicator:Node3D = $Indicator

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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ui.visible = false
	if is_moved_as_indicator:
		dragged_element = indicator
	else:
		dragged_element =  get_parent_node_3d()
		indicator.visible = false

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
				cursor.pick_up(self)
				on_pick_up(interact_type)

func on_pick_up(interact_control:Cursor.CursorTarget)->void:
	var area3d:Area3D
	if is_moved_as_indicator:
		area3d = indicator.get_node("Area3D")
	else:
		area3d = $Area3D
	for area in area3d.get_overlapping_areas():
		if area.is_in_group("Dropoff"):
			var dropoff = area.get_parent() as Dropoff
			if dropoff.interact_type == interact_control:
				dropoff._remove_entity(self)
				break;

func on_place(interact_control:Cursor.CursorTarget) -> void:
	var dropped:bool = false
	var area3d:Area3D
	if is_moved_as_indicator:
		area3d = indicator.get_node("Area3D")
	else:
		area3d = $Area3D
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

func _process(_delta: float) -> void:
	if dragging and follow_target:
		dragged_element.global_position = follow_target.global_position

func reset_position() ->void:
	on_pick_up(interact_type)
	var tween = get_tree().create_tween()
	tween.tween_property(dragged_element, "global_position", first_position, 0.6)
