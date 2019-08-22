extends Control

"""
	Control the panel that appear when the player wins the level
"""

var base

#world nodes
onready var panel = $Panel

#initialiaze
func init(base):
	self.base = base
	
	self.base.game.connect('game_won',self,'show_panel')

#ending screen and all the information
func show_panel():
	panel.show()
	
	#TODO: fill points, score etc...