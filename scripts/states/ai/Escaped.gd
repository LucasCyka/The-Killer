extends Node

"""
	Teenager escaped state
	
	This is a point-of-no-return state.
"""

signal finished
signal entered

var game
var base

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	
	emit_signal("entered")
	
	game = base.teenager.get_parent().get_parent()
	#the player lost the game here
	game.set_current_mode(game.MODE.GAMEOVER)
	
func update(delta):
	pass
	
#destructor
func exit():
	emit_signal("finished")