extends Control

"""
	This UI element will control the placement of traps.
"""

signal new_trap

var base = null

#constructor
func init(base):
	self.base = base

#TODO: open a panel showing all the lure traps available for this level
func lure_btn():
	#this will prevent the player from choosing two traps at the same time
	emit_signal("new_trap")
	
	#only spawn the first lure trap for now...
	var lure = preload("res://scenes/traps/LureTrap.tscn").instance()
	lure.init(base.game,base.get_lure_tilemap(),lure,self)
	base.game.add_child(lure)
	

#TODO: open a panel showing all the misc traps available for this level
func misc_btn():
	emit_signal("new_trap")
	
	#only spawn the first misc trap for now...
	var misc = preload("res://scenes/traps/MiscTrap.tscn").instance()
	misc.init(base.game,base.get_lure_tilemap(),misc,self)
	base.game.add_child(misc)
	
