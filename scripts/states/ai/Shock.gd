extends Node

"""
	Teenager Shock state
"""

signal finished
signal entered

var base

#constructor
func init(base,state_position,state_time):
	emit_signal("entered")
	self.base = base
	base.teenager.state_animation = true
	self.base.is_forced_state = false
	self.base.connect("timer_finished",self,"exit")
	
func update(delta):
	pass
	
#destructor
func exit():
	if not base.is_forced_state:
		if base.is_connected("timer_finished",self,"exit"):
			base.disconnect("timer_finished",self,"exit")
		
		if not self.base.teenager.is_escaping:
			base.force_state('Panic')
		else:
			#he's already escaping
			base.force_state('Escaping')






