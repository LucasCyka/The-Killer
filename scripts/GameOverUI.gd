extends Control

"""
	Controls the game over screen.
"""

var base = null

#world nodes
onready var panel = $Panel

#initialize
func init(base):
	self.base = base
	
	#connect to the signal that will be emitted when the player lost the game
	self.base.game.connect("game_over",self,"show_screen")
	
func show_screen():
	panel.show()
	
func restart():
	star.clear()
	get_tree().reload_current_scene()
	
func quit():
	get_tree().quit()