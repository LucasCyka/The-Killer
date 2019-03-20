extends "res://scripts/FSM.gd"

"""
	The Finite state machine for the player (hunter).
"""


#initialize
func _ready():
	var states = {
		$Deployment:$Deployment.name,
		$Spawning:$Spawning.name,
		$Idle:$Idle.name,
		$Moving:$Moving.name,
		$Attacking:$Attacking.name
	}
	player = get_parent()
	
	stack = [$Deployment]
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
	