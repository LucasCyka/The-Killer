extends Control

"""
	Base class for the all the user interface elements in the game.
"""

#UI elements
var teenager_panel = null
var traps_ui = null
var misc_ui = null
var game = null

#instantiate and initialize ui elements
func _ready():
	teenager_panel = get_node("Canvas/TeenagerInfo")
	traps_ui = get_node("Canvas/TrapsUI")
	misc_ui = get_node("Canvas/MiscUI")
	
	game = get_parent()
	
	teenager_panel.init(self)
	traps_ui.init(self)
	misc_ui.init(self)
	
#return an array containing selection buttons for each teenager
func get_teenagers_buttons():
	var teenagers = []

	for teenager in game.get_teenagers():
		teenagers.append(teenager.get_node("KinematicTeenager/TeenagerButton"))
		
	return teenagers

#return the tilemap where lure traps can be build
func get_lure_tilemap():
	return game.get_floor_tile()
	#TODO: return instead the A* tilemap
