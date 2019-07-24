extends Node

"""
	Teenager screaming state
	
	When screaming, a teenager can alert others nearby.
"""

signal finished
signal entered

var base

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = true
	emit_signal("entered")
	
func update(delta):
	pass
	
#destructor
func exit():
	emit_signal("finished")