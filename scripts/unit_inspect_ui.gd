class_name UnitUI extends Control

@onready var stats:CharacterStats = $".."

@onready var stat_graph:StatGraph = $Background/PolyStat/StatGraph

# Called when the node enters the scene tree for the first time.
func display() -> void:
	var stat_array:Array = [stats.might, stats.guile, stats.favor]
	stat_graph.display_stats(stat_array)
