extends Node

"""
	Hunter Moving state
"""

signal finished

var base
var target

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.target = state_position
	
func update(delta):
	#move to the target
	if base.player.walk(target):
		transitions()
	
func input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("ok_input"):
			target = base.player.mouse_position

#detect transitions between states
func transitions():
	### MOVING TO IDLE ###
	base.stack.append(base.get_node("Idle"))
	exit()

#destructor
func exit():
	emit_signal("finished")