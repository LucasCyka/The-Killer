extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

#the tileset the trap will lay
var tiles = null
var base = null
var child = null
var ui = null

#teenager modifiers
var curiosity = 10
var fear = 1

#constructor
func init(base,tiles,child,ui):
	self.base = base
	self.tiles = tiles
	self.child = child
	self.ui = ui
	
	#replace traps, needs to diconnect this when the trap is placed
	ui.connect("new_trap",self,"exit")

##traps effects##
func enter_panic():
	pass

func increase_fear():
	pass

func increase_curiosity():
	pass

func cripple():
	pass
##
#TODO: check if the teenager isn't in panic mode
#make the teenager enters on the 'lured state'
func lure_teenager(teenager):
	teenager.state_machine.force_state('Lured')

#destructor
func exit():
	child.queue_free()