extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

#TODO: make curiosity modifiers act more at traps? Maybe a trap is too dull
#and the teenager can only fall for it if he has an certain curiosity level.

enum TYPES{
	BUMP,
	LURE,
	MISC,
	VICE,
	NULL
}
var type = TYPES.NULL

var id = 0

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
func init(id,base,tiles,child,ui,curiosity,fear):
	self.id = id
	self.base = base
	self.tiles = tiles
	self.child = child
	self.ui = ui
	self.curiosity = curiosity
	self.fear = fear
	
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
	#check if the teenager can be OnVice state
	if teenager.state_machine.check_forced_state('OnVice'):
		teenager.state_machine.state_time = 6 #TODO: maybe take this number from the trap?
		teenager.set_trap(self)
		teenager.state_machine.force_state('OnVice')
		
		return true

##
#make the teenager enters on the 'lured state'
func lure_teenager(teenager):
	#check if the teenager can be lured
	if teenager.state_machine.check_forced_state('Lured'):
		if teenager.get_traps().size()> 0:
			#remove any other lure trap
			for lure in teenager.get_traps():
				if lure != child:
					lure.is_used = false
					teenager.remove_trap(lure,true)
		
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

#activate a trap again
func activate_trap(teenager):
	if type == TYPES.VICE:
		child.set_process(true)
		child.is_used = false
		var pos = child.texture.global_position
		
		#check if the trap is close enough to the teenager to be activated
		#right away
		if teenager.kinematic_teenager.global_position.distance_to(pos) < 30:
			if teenager.state_machine.check_forced_state('OnVice'):
				teenager.state_machine.force_state('OnVice')
		else:
			teenager.remove_trap(self,false)
		
	elif type == TYPES.LURE:
		child.is_used = false
		#check if it can be activated right away
		if teenager.state_machine.check_forced_state('Lured'):
			teenager.state_machine.force_state('Lured')
			child.is_used = true
		else:
			#can't be activated again? remove it from the teenager trap list
			#then.
			teenager.remove_trap(self,false)

func deactivate_trap():
	if type == TYPES.VICE:
		child.set_process(false)
		child.is_used = true
	else:
		child.is_used = true

#destructor
func exit():
	child.queue_free()