class_name Character extends Node

@onready var stats : CharacterStats = $CharacterPieces/CharacterStats
@onready var movement : Node3D = $CharacterPieces/CharacterMovement
@onready var pickupTarget : PickupTarget = $CharacterPieces/CharacterMovement/pickup_target

@export var character_name = ""

func _ready() -> void:
	character_name = NameGenerator.generate_name()

func tween_global_position(target_position : Vector3, travel_time : float) -> Tween:
	var tween = get_tree().create_tween()
	tween.tween_property(movement, "global_position", target_position, travel_time)
	return tween
	
