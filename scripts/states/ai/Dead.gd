extends Node

"""
	Teenager dead state
"""

signal finished

#constructor
func init(base,state_position,state_time):
	pass
	
func update(delta):
	#TODO: sync dead animation with player attacking animation
	pass
	
#destructor
func exit():
	emit_signal("finished")