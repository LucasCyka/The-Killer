extends Node

"""
	Teenager Idle state
"""

signal finished

func init(base,state_position,state_time):
	pass
	
func update(delta):
	pass
	
func exit():
	emit_signal("finished")