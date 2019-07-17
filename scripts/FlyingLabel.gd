extends Node2D

"""
	A label that will fly up along the y axis then disappears.
"""

var text = '0000000'
var y_max = 50
onready var y_start = global_position.y
var speed = 1

#initialize
func _ready():
	$Label.text = text

func _physics_process(delta):
	global_position= Vector2(global_position.x,global_position.y-speed)
	
	if global_position.y <= y_start-y_max:
		set_physics_process(false)
		call_deferred('free')