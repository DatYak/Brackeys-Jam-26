extends Node3D

var pickedup:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _pickup() -> void:
	pickedup = true

func release() -> void:
	pickedup = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pickedup:
		
