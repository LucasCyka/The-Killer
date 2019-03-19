extends Node

"""
	Teenager Moving state
"""

signal finished

var base
var teenager = null
var position = null

func init(base,state_position,state_time):
	teenager = base.teenager
	position = state_position
	self.base = base
	
	
func update(delta):
	if teenager == null:
		return
	
	#walk to that location
	if teenager.walk(position):
		exit()
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	
	teenager = null
	position = null
	emit_signal("finished")