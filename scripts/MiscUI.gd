extends Control

"""
	Miscellaneous  elements of the user interface
"""

var base = null

#constructor
func init(base):
	self.base = base

#hunt button pressed state
func hunt():
	var hunter = preload("res://scenes/PlayerHunter.tscn").instance()
	pass 
