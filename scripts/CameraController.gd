class_name CameraController extends Camera3D

@export var speed = 5
@export var radius = 10
@export var travel_time = 1
var height = 10.5
var adjusted_center_point : Vector3

var input_enabled = true

func _ready() -> void:
	adjusted_center_point = position
	center_on_point(Vector3(0,0,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if (not input_enabled):
		return
		
	var input_dir := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	
	var new_position = position
	new_position.x += input_dir.x * speed * delta
	new_position.z -= input_dir.y * speed * delta
	
	if new_position.distance_to(adjusted_center_point) <= radius:
		position = new_position

func center_on_point(point : Vector3):
	input_enabled = false
		
	var backwardsVector = basis.z
	var scalar = height / backwardsVector.y
	adjusted_center_point = point + (scalar * backwardsVector)
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", adjusted_center_point, travel_time)
	tween.tween_callback(enable_input)
	


func enable_input():
	input_enabled = true
