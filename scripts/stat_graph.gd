class_name StatGraph extends Control


@export var stats: Array = [0, 0, 0]
@export var max_stat: = 4.0
@export var max_vertex_distance:float = 45
@export var min_vertex_distance:float = 5
@onready var angle_inc:float = 360.0 / 3.0

var points: Array = [
	[0,0],
	[0,0],
	[0,0]
]

var polygon : PackedVector2Array

func float_array_to_Vector2Array(coords : Array) -> PackedVector2Array:
	# Convert the array of floats into a PackedVector2Array.
	var array : PackedVector2Array = []
	for coord in coords:
		array.append(Vector2(coord[0], coord[1]))
	return array

func _ready():
	display_stats(stats)

func display_stats(new_stats:Array):
	stats = new_stats
	var angle:float= 0
	for i in range(len(stats)):
		var stat_value = stats[i] / max_stat
		stat_value = lerp(min_vertex_distance, max_vertex_distance, stat_value)
		#Positive Y is down, flip graph
		var stat_vector = Vector2(0, -stat_value)
		stat_vector = stat_vector.rotated(deg_to_rad(angle))
		points[i] = stat_vector
		angle += angle_inc
	
	polygon = float_array_to_Vector2Array(points);
 	
func _draw() -> void:
	var red : Color = Color("D95F02")
	var blue : Color = Color("4DAF4A")
	var green : Color = Color("3A8EBA")
	draw_polygon(polygon, [ red, blue, green ])
