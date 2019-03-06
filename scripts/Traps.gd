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

#if the trap is placed in an invalid location this will be true
var is_invalid_tile = false setget set_is_invalid_tile

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
func enter_panic(teenager):
	teenager.state_machine.force_state('Panic')

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

#the trap becomes transparent when is in an invalid location
func set_is_invalid_tile(value):
	is_invalid_tile = value
	if is_invalid_tile:
		child.get_node("Texture").set_self_modulate(Color(1,1,1,0.5))
	else: child.get_node("Texture").set_self_modulate(Color(1,1,1,1))
		

#destructor
func exit():
	child.queue_free()