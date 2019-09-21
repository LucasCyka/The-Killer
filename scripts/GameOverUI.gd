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
	self.base.game.connect("game_over_music",self,"show_screen")
	
func show_screen():
	panel.show()
	
func restart():
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.free()
	
	#TODO: loading screen
	get_tree().reload_current_scene()
	star.clear()
	
func quit():
	for teen in get_tree().get_nodes_in_group("AI"):
		teen.free()
	
	get_tree().change_scene("res://scenes/MainMenu.tscn")
	star.clear()
	