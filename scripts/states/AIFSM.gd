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

#the next state that will be executed when the current one isn't occupied.
var state_on_queue = null setget set_state_queue

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
		$Startled:$Startled.name,
		$Crippled:$Crippled.name,
		$Shock:$Shock.name,
		$Fighting:$Fighting.name,
		$Cornered:$Cornered.name,
		$Screaming:$Screaming.name,
		$Escaped:$Escaped.name,
		$Talking:$Talking.name,
		$Sleeping:$Sleeping.name,
		$EatingTable:$EatingTable.name,
		$OnPicNic:$OnPicNic.name,
		$Shitting:$Shitting.name,
		$OnBed:$OnBed.name,
		$SittingFloor:$SittingFloor.name,
		$Fishing:$Fishing.name,
		$InLove:$InLove.name,
		$CheckingLight:$CheckingLight.name,
		$Barricading:$Barricading.name,
		$Naked:$Naked.name,
		$Working:$Working.name
	}
	
	for state in states:
		if not state.is_connected("finished",self,"finish_state"):
			state.connect("finished",self,"finish_state")
			
		if not state.is_connected("entered",self,"_queue_state"):
			state.connect("entered",self,"_queue_state")
	
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
	if not is_forced_state and teenager.get_traps().size() > 0:
		teenager.get_traps()[teenager.current_trap].activate_trap(teenager)
		#print("STACKED TRAPS:")
		#print(teenager.traps.size())
	if _on_routine == true and is_routine_over == false:
		#check if the routine is paused, if so then resume it instead
		#of going to the next one
		if teenager.is_routine_paused:
			#print("resuming routine...")
			teenager.resume_routine()
			return
		teenager.next_routine()
	else:
		#print("is forced")
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

#this will check if there's any state on queue to be executed
func _queue_state():
	if state_on_queue == null:
		#there's no state on queue, just continue the current one
		return
	
	if not check_forced_state(state_on_queue.name):
		#this state cannot be executed at the moment
		state_on_queue = null
		return false
	
	if not teenager.is_routine_paused:
		teenager.pause_routine()
	
	var next_state = get_node(state_on_queue.name)
	state_on_queue = null
	
	is_forced_state = true
	current_state.exit()
	_on_routine = false
	change(next_state)
	
	return true
	
func set_state_queue(state):
	state_on_queue = get_node(state)

#check if a given state can be forced on this teenager
func check_forced_state(state):
	#check if this state is compatible
	#some states  cannot be connected to the state the ai is trying to change.
	if current_state.name == 'Panic' and state == 'Panic':
		state_time = 2
		force_state("Shock")
		return false
	if current_state.name == 'Dead':
		return false
	if state == 'Panic' and current_state.name == 'Escaping':
		state_time = 1
		force_state("Shock")
		return false
	if state == 'OnVice' and current_state.name == 'Panic' or (current_state.name == 'Escaping' and state == 'OnVice'):
		return false
	if state =='Panic' and current_state.name == 'Crippled':
		return false 
	if state == 'Panic' and current_state.name == 'Barricading':
		state_time = 1
		force_state("Shock")
		return false
	if state == 'Escaping' and current_state.name == 'Crippled':
		return false
	if state == 'Startled' and current_state.name == 'Escaping':
		return false
	if state == 'Startled' and current_state.name == 'Panic':
		return false
	if state == 'Startled' and current_state.name == 'Sleeping':
		if teenager.traits.keys().find(10) != -1: return false
	if state == 'Lured' and current_state.name == 'Panic':
		return false
	if state == 'Lured' and current_state.name == 'Escaping':
		return false
	if current_state.name == 'Escaped':
		return false
	if state == 'InLove' and current_state.name == 'Escaping':
		return false
	if state == 'InLove' and current_state.name == 'Panic':
		return false
	if state == 'InLove' and current_state.name == 'Screaming':
		return false
	if state == 'CheckingLight' and current_state.name == 'Sleeping':
		return false
	if state == 'CheckingLight' and current_state.name == 'Panic':
		return false
	if state == 'CheckingLight' and current_state.name == 'Shock':
		return false
	if state == 'CheckingLight' and current_state.name == 'Screaming':
		return false
	if state == 'CheckingLight' and current_state.name == 'Crippled':
		return false
#	if state == 'Panic' and current_state.name == 'Shock':
#		return false
	
	return true

