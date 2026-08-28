class_name FadingNotification extends Control

@onready var label:Label = $Panel/Label
@export var transition_duration : float = 0.15

func setup(text:String, duration:float) -> void:
	global_position = Vector2(0, - (get_viewport_rect().size.y/2) - 100)
	var end_pos = Vector2(0, (get_viewport_rect().size.y/2) + 100)
	label.text = text
	
	# Account for duration in time
	var disply_duration = duration - (transition_duration * 2)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", Vector2(0,0), transition_duration)
	tween.tween_interval(disply_duration)
	tween.tween_property(self, "global_position", end_pos, transition_duration)
	tween.tween_callback(queue_free)
