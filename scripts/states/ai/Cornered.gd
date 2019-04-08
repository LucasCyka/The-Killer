extends Node

"""
	Teenager cornered state
	
	When cornered a teenager can only fight or scream for help.
	
	His/her decision will be made according to his/her traits, modifiers etc.
	e.g, a woman will be much more likely to jus start screaming than fighting
	the player.
	
"""

var base

signal finished
signal entered

#constructor
func init(base,state_position,state_time):
	self.base = base
	
	emit_signal("entered")
	
	#TODO: check the modifiers before making a decision.
	#only start screaming for now.
	base.force_state('Screaming')
	
	
func update(delta):
	pass
	
#destructor
func exit():
	emit_signal("finished")