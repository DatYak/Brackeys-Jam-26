class_name Character extends Node

@onready var stats : CharacterStats = $CharacterPieces/CharacterStats
@onready var movement : CharacterMovement = $CharacterPieces/CharacterMovement

@export var character_name = ""

func _ready() -> void:
	character_name = NameGenerator.generate_name()
