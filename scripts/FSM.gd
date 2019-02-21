extends Node

"""
	Base class for finite state machines.
	It change, update and initialize states.
"""

var current_state = null

#if the state has a location where it should be performed.
#each state deals with it in a different way
var state_position = Vector2(0,0)

#for how much longer the npc should reamin on this state? (in seconds)
var state_time = 10

func init():
	current_state.init(state_position,state_time)

#update the state process function
func _physics_process(delta):
	if current_state == null:
		return
		
	current_state.update(delta)

#change to a new state
func change(state):
	current_state = state
	self.init()