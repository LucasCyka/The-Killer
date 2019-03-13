extends Node

"""
	Teenager OnVice state
"""

signal finished

var base

#constructor
func init(base,state_position,state_time):
	self.base = base
	base.connect("timer_finished",self,"exit")
	
	#TODO: wait a time before consuming the trap
	base.teenager.get_traps()[0].queue_free()
	base.teenager.traps = []
	
func update(delta):
	pass
	
func exit():
	base._on_routine = true
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")