extends Node2D

"""
	Control lots of the aspects about the gameplay.
	Things like game over events, points distribution, world information etc...
"""

#TODO: INITIALIZE
func _ready():
	pass

#return all the teenagers in the game
func get_teenagers():
	return get_tree().get_nodes_in_group("AI")