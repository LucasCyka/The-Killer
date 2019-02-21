extends Node

"""
	Teenager waiting state
"""

signal finished

func init(state_position,state_time):
	print("wait here ")
	pass
	
func update(delta):
	pass
	
func exit():
	emit_signal("finished")