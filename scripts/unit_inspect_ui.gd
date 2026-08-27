class_name UnitUI extends Control

@onready var stats:CharacterStats = $".."
@onready var character:Character = $"../../.."

@onready var stat_graph:StatGraph = $Background/PolyStat/StatGraph
@onready var name_label : Label = $Background/Nameplate/Label
@onready var image:TextureRect = $Background/Image

# Called when the node enters the scene tree for the first time.
func display() -> void:
	var stat_array:Array = [stats.might, stats.guile, stats.favor]
	stat_graph.display_stats(stat_array)
	
	name_label.text = character.character_name
	image.texture = character.character_image
	
