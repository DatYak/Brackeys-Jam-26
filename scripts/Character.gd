class_name Character extends Node

@onready var stats : CharacterStats = $CharacterPieces/CharacterStats
@onready var movement : CharacterMovement = $CharacterPieces/CharacterMovement

var character_name = ""

func _ready() -> void:
	var name_generator = NameGenerator.new() #id rather use a factory singleton to prevent duplicates but this is easiest for now
	character_name = name_generator.generateName()
