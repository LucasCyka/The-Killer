extends Control

"""
	Base class for the all the user interface elements in the game.
"""

signal element_toggle
signal element_mouse_hover
signal element_mouse_exit

#UI elements
var teenager_panel = null
var traps_ui = null
var misc_ui = null
var info_ui = null
var game = null

#instantiate and initialize ui elements
func _ready():
	teenager_panel = get_node("Canvas/TeenagerInfo")
	traps_ui = get_node("Canvas/TrapsUI")
	misc_ui = get_node("Canvas/MiscUI")
	info_ui = get_node("Canvas/InfoUI")
	
	game = get_parent()
	
	teenager_panel.init(self)
	traps_ui.init(self)
	misc_ui.init(self)
	info_ui.init(self)
	
	#detect when a element in the ui is used and hovered
	var buttons = get_buttons()
	for button in buttons:
		button.connect("pressed",self,"_on_toggle")
		button.connect("mouse_entered",self,"_on_hover")
		button.connect("mouse_exited",self,"_on_exit")
	
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

func get_bump_tilemap():
	return game.get_wall_tile()

#return all the buttons used in the ui
func get_buttons():
	var buttons = traps_ui.get_child(0).get_children() 
	buttons = buttons + misc_ui.get_child(0).get_children()
	
	for element in buttons:
		if !element is TextureButton:
			buttons.erase(element) #this can cause an error in the loop, idk...
	
	return buttons

#lock all elements in the user interface
func lock():
	#lock buttons
	for btn in get_buttons():
		if btn is TextureButton:
			btn.set_disabled(true)
		
#unlock all elements of the user interface
func unlock():
	#unlock buttons
	for btn in get_buttons():
		if btn is TextureButton:
			btn.set_disabled(false)

#this signal is emmited when a new element in the user interface is used
func _on_toggle():
	emit_signal("element_toggle")

#this signal is emmited when an element in the ui is being hover
func _on_hover():
	emit_signal("element_mouse_hover")

func _on_exit():
	emit_signal("element_mouse_exit")





