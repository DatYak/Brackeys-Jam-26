class_name CameraController extends Camera3D

@export var speed = 12.0
@export var radius = 20.0
@export var travel_time = 1.0

@export var zoom_speed = 5.0
@export var min_zoom_height = 7.0
@export var max_zoom_height = 15.0

var default_height = 0.0
var adjusted_center_point : Vector3

var input_enabled = true

func _ready() -> void:
	default_height = position.y
	adjusted_center_point = position
	center_on_point(Vector3(0,0,0))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_process_input(delta)
		
	

func center_on_point(point : Vector3):
	input_enabled = false
		
	var backwardsVector = basis.z
	var scalar = default_height / backwardsVector.y
	adjusted_center_point = point + (scalar * backwardsVector)
		
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", adjusted_center_point, travel_time)
	tween.tween_callback(enable_input)

func _process_input(delta: float):
	if (not input_enabled):
		return
	
	_process_pan_input(delta)
	_process_zoom_input(delta)

func _process_pan_input(delta: float):
	var input_dir := Input.get_vector("move_left", "move_right", "move_down", "move_up")
	
	var new_position = position
	new_position.x += input_dir.x * speed * delta
	new_position.z -= input_dir.y * speed * delta
	
	if new_position.distance_to(adjusted_center_point) <= radius:
		position = new_position
	
func _process_zoom_input(delta: float):
	var zoom = 0
	if (Input.is_action_just_pressed("zoom_out")):
		zoom = -1
	if (Input.is_action_just_pressed("zoom_in")):
		zoom = 1
	var new_position = position
	new_position += -basis.z * zoom_speed * delta * zoom
	
	if new_position.y > min_zoom_height and new_position.y < max_zoom_height and new_position.distance_to(adjusted_center_point) <= radius:
		position = new_position


func enable_input():
	input_enabled = true
