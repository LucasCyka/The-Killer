extends Node

"""
	Teenager dead state
"""

signal finished
signal entered

var base
var game

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.game = base.teenager.get_parent().get_parent()
	
	#TODO: points should be weighted different according to some teenagers
	#modifiers.
	score.set_score(game.get_level(),score.get_score(game.get_level()) + 100)
	
	
	emit_signal("entered")
	
func update(delta):
	#TODO: sync dead animation with player attacking animation
	pass
	
#destructor
func exit():
	emit_signal("finished")