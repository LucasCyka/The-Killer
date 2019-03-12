extends Node

"""
	Teenager Fight-or-flight state.
"""

signal finished

var base

func init(base,state_position,state_time):
	pass
	
func update(delta):
	pass
	
func exit():
	emit_signal("finished")