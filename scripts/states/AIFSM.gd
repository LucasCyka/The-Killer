extends "res://scripts/FSM.gd"

"""
	The Finite state machine for each AI (teenager).
"""

#certain states deactivate routines
var _on_routine = false

#teenager base node
onready var teenager = get_parent()

#initialize state machine
func _ready():
	var states = {
		$Idle:$Idle.name,
		$Moving:$Moving.name,
		$Waiting: $Waiting.name
	}
	
	for state in states:
		if not state.is_connected("finished",self,"finish_state"):
			state.connect("finished",self,"finish_state")
	
	current_state = $Idle
	init()

func get_current_state():
	return current_state.name

#execute a state from the player's routine
func execute_routine(state,position,time):
	state_position = position
	state_time = time
	_on_routine = true
	change(get_node(state))
	#state information

#if is following a routine, tell the player base AI that this step is over
#otherwise, just follow to the next
func finish_state():
	if _on_routine == true:
		_on_routine = false
		teenager.next_routine()
	else:
		#external events will prevent this teenager from executing
		#routine state.
		pass
		

#forces the AI to start a new routine
func force_new_routine():
	pass

#force a new state change. Generally used by traps or the player.
func force_state(state):
	pass

#detect transitions between states
func state_transitions():
	pass






