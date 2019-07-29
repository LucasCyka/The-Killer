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
	
	#custom balloon over the teen's head
	self.base.teenager.update_thinking_balloon(false,['screaming'])
	self.base.teenager.is_talking = false
	self.base.teenager.is_thinking = false
	
	emit_signal("entered")
	
func update(delta):
	pass
	
#destructor
func exit():
	emit_signal("finished")