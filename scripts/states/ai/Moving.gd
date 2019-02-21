extends Node

"""
	Teenager Moving state
"""

signal finished

var teenager = null
var position = null

func init(state_position,state_time):
	teenager = get_parent().get_parent()
	position = state_position
	
func update(delta):
	if teenager == null:
		return
	
	#walk to that location
	if teenager.walk(position):
		exit()
	
func exit():
	teenager = null
	position = null
	emit_signal("finished")