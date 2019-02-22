extends Control

"""
	Base class for the all the user interface elements in the game.
"""

#UI elements
var teenager_panel = null

#instantiate and initialize ui elements
func _ready():
	teenager_panel = get_node("Canvas/TeenagerInfo")
	
	teenager_panel.init(self)

#return an array containing selection buttons for each teenager
func get_teenagers_buttons():
	var teenagers = []
	var game = get_parent()

	for teenager in game.get_teenagers():
		teenagers.append(teenager.get_node("KinematicTeenager/TeenagerButton"))
		
	return teenagers
