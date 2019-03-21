extends "res://scripts/FSM.gd"

"""
	The Finite state machine for each AI (teenager).
"""

#certain states deactivate routines
var _on_routine = false

#this will be true when something forces the teenager out of the routine.
#when is false and a teenager isn't in panic they'll go back to their routines
var is_forced_state = false

#replaces is_chain_reaction. When true that means that this teenager can't
#go back to his routines. Must be activated when he's escaping or in panic
var is_routine_over = false


#initialize state machine
func _ready():
	var states = {
		$Idle:$Idle.name,
		$Moving:$Moving.name,
		$Waiting: $Waiting.name,
		$Lured: $Lured.name,
		$Panic: $Panic.name,
		$Escaping: $Escaping.name,
		$Dead:$Dead.name,
		$OnVice:$OnVice.name,
		$Startled:$Startled.name
	}
	
	for state in states:
		if not state.is_connected("finished",self,"finish_state"):
			state.connect("finished",self,"finish_state")
	
	current_state = $Idle
	state_timer = $StateTimer
	#timeout signal
	state_timer.connect("timeout",self,"timeout")
	
	teenager = get_parent()
	init()

func get_current_state():
	return current_state.name

#execute a state from the player's routine
func execute_routine(state,position,time):
	state_position = position
	state_time = time
	_on_routine = true
	change(get_node(state))

#if is following a routine, tell the player base AI that this step is over
#otherwise, just follow to the next
func finish_state():
	if _on_routine == true and is_routine_over == false:
		#TODO: check if the routine is paused, if so then resume it instead
		#of going to the next one
		if teenager.is_routine_paused:
			print("resuming routine...")
			teenager.resume_routine()
			return
		teenager.next_routine()
	else:
		print("is forced")
		#external events will prevent this teenager from executing
		#routine states.
		pass
		

#forces the AI to start a new routine
func force_new_routine():
	pass

#force a new state change. Generally used by traps or the player.
func force_state(state):
	if not check_forced_state(state):
		#this state cannot be forced at the moment
		return false
	
	if not teenager.is_routine_paused:
		teenager.pause_routine()
	
	is_forced_state = true
	current_state.exit()
	_on_routine = false
	change(get_node(state))
	
	return true

#check if a given state can be forced on this teenager
func check_forced_state(state):
	#check if this state is compatible
	#some states  cannot be connected to the state the ai is trying to change.
	if state == current_state.name or current_state.name == 'Dead':
		return false
	if state == 'Panic' and current_state.name == 'Escaping':
		return false
	if state == 'OnVice' and current_state.name == 'Panic' or (current_state.name == 'Escaping' and state == 'OnVice'):
		return false
		
	return true

