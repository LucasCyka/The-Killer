extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

#the tileset the trap will lay
var tiles = null
var base = null
#teenager modifiers
var curiosity = 10
var fear = 1

#constructor
func init(base,tiles):
	self.base = base
	self.tiles = tiles

#TODO: check if the teenager isn't in panic mode
#TODO: check the teenager is trapped in another trap, if so this is a chain reaction
#and the state machine needs to be warned about that.
#make the teenager enters on the 'lured state'
func lure_teenager(teenager):
	teenager.state_machine.force_state('Lured')