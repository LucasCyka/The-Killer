extends Node2D

"""
	Control the tutorial in the first level
"""

#world nodes
onready var text_box = $CanvasLayer/TextBox
onready var text = $CanvasLayer/TextBox/Label

var current_step = 0

var tutorial_text = {}

#init tutotiral
func _ready():
	#load tutorial text
	var file = File.new()
	


#show the textbox
func show_text(t,lower_sounds=true):
	pass

#pause game
func pause():
	pass

#resume game
func resume():
	pass

#advance the tutorial foward
func next_step():
	pass
	












