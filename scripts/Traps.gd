extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

enum TYPES{
	BUMP,
	LURE,
	MISC,
	VICE,
	NULL
}
var type = TYPES.NULL

#the tileset the trap will lay
var tiles = null
var base = null
var child = null
var ui = null

#if the trap is placed in an invalid location this will be true
var is_invalid_tile = false setget set_is_invalid_tile

#if the trap is inside a building or not
var is_indoor = false setget set_is_indoor

#trap modifiers
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
	
	#TODO: change trap modifiers according to their ids.
	
##traps effects - most used by misc and vice traps##
func enter_panic(teenager):
	teenager.state_machine.force_state('Panic')

func decrease_speed(teenager):
	teenager.set_slow(true)

func increase_fear():
	pass

func increase_curiosity():
	pass

func cripple():
	pass

func activate_vice(teenager):
	teenager.state_machine.state_time = 6 #TODO: maybe take this number from the trap?
	teenager.state_machine.force_state('OnVice')

##
#make the teenager enters on the 'lured state'
func lure_teenager(teenager):
	#check if the teenager can be lured
	if teenager.state_machine.check_forced_state('Lured'):
		#TODO: check if this trap is compatible with the teenager
		teenager.set_trap(self)
		teenager.state_machine.force_state('Lured')
		
		return true

func startle_teenager(teenager,pos):
	if teenager.state_machine.check_forced_state('Startled'):
		teenager.set_trap(self)
		teenager.state_machine.state_position = pos
		teenager.state_machine.force_state('Startled')

#the trap becomes transparent when is in an invalid location
func set_is_invalid_tile(value):
	is_invalid_tile = value
	if is_invalid_tile:
		child.get_node("Texture").set_self_modulate(Color(1,1,1,0.5))
	else: child.get_node("Texture").set_self_modulate(Color(1,1,1,1))
		
func set_is_indoor(value):
	is_indoor = value

#destructor
func exit():
	child.queue_free()