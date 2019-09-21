extends Control

"""
	Controll the buttons of the option menu screen.
"""

#start button pressed event
func on_start():
	self.hide()
	
	var level_selection = preload("res://scenes/LevelsSelection.tscn").instance()
	get_parent().add_child(level_selection)