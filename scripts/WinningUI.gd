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
	
	self.base.game.connect('game_won_music',self,'show_panel')

#ending screen and all the information
func show_panel():
	panel.show()
	
	#TODO: fill points, score etc...
	
#goes to the main menu
func menu_btn():
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.queue_free()
	
	star.clear()
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	
#restarts game
func restart_btn():
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.queue_free()
	
	star.clear()
	get_tree().reload_current_scene()