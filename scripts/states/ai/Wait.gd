extends Node

"""
	Teenager waiting state
"""

signal finished

var base

#CONSTRUCTOR
func init(base,state_position,state_time):
	self.base = base
	base.connect("timer_finished",self,"exit")
	
func update(delta):
	pass
	
func exit():
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")