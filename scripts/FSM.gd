extends Node

"""
	Base class for finite state machines.
	It change, update and initialize states.
"""

signal timer_finished

var current_state = null
var state_timer = null
var teenager = null
var player = null
var stack = []

#if the state has a location where it should be performed.
#each state deals with it in a different way
var state_position = Vector2(0,0)

#for how much longer the npc should reamin on this state? (in seconds)
var state_time = 10

func init():
	state_timer.stop()
	state_timer.set_wait_time(state_time)
	state_timer.start()
	
	current_state.init(self,state_position,state_time)
	
	if teenager != null:
		#teenager debug progress
		teenager.get_node("Animations/StateProgress").set_value(0)
		teenager.get_node("Animations/StateProgress").set_max(state_time)
	elif player != null:
		player.get_node("StateProgress").set_value(0)
		player.get_node("StateProgress").set_max(state_time)
	
#update the state process function
func _physics_process(delta):
	if current_state == null:
		return
		
	current_state.update(delta)
	
	if teenager != null:
		#teenager debug progress
		teenager.get_node("Animations/StateProgress").set_value(state_time - state_timer.get_time_left())
	if player != null:
		#player debug progress
		player.get_node("StateProgress").set_value(state_time - state_timer.get_time_left())

#get player input to states
func _input(event):
	if player != null and current_state != null:
		current_state.input(event)

#change to a new state
func change(state):
	current_state = state
	self.init()

#the time for a given state is over
func timeout():
	emit_signal("timer_finished")