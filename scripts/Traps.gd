extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

#the tileset the trap will lay
var tiles = null
var base = null
var child = null
#teenager modifiers
var curiosity = 10
var fear = 1

#constructor
func init(base,tiles,child):
	self.base = base
	self.tiles = tiles
	self.child = child

#TODO: check if the teenager isn't in panic mode
#make the teenager enters on the 'lured state'
func lure_teenager(teenager):
	teenager.state_machine.force_state('Lured')
	