class_name Character extends Node

@onready var stats : CharacterStats = $CharacterStats
@onready var movement : CharacterMovement = $CharacterMovement

var character_name = ""

func _ready() -> void:
	var name_generator = NameGenerator.new() #id rather use a factory singleton to prevent duplicates but this is easiest for now
	character_name = name_generator.generateName()
