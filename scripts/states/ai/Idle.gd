extends Node

"""
	Teenager Idle state
"""

signal finished

var base

func init(base,state_position,state_time):
	self.base = base
	pass
	
func update(delta):
	pass
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	emit_signal("finished")