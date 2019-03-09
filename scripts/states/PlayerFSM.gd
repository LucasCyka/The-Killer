extends "res://scripts/FSM.gd"

"""
	The Finite state machine for the player (hunter).
"""

onready var stack = [$Deployment]

#initialize
func _ready():
	var states = {
		$Deployment:$Deployment.name
	}
	player = get_parent()
	
	current_state = stack[0]
	state_timer = $StateTimer
	#timeout signal
	state_timer.connect("timeout",self,"timeout")
	
	for state in states:
		state.connect("finished",self,"finish_state")
	
	init()

#called when a state is over
func finish_state():
	stack.pop_front()
	change(stack[0])
	
func get_current_state():
	return current_state.name