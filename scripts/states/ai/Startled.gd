extends Node

"""
	Teenager startled state
"""

signal finished

var base

#constructor
func init(base,state_position,state_time):
	self.base = base
	
func update(delta):
	pass
	
#destructor
func exit():
	emit_signal("finished")