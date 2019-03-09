extends Control

"""
	This UI element will control the placement of traps.
"""

signal new_trap

var base = null
var is_ui_occupied = false setget set_is_ui_occupied

#constructor
func init(base):
	self.base = base
	self.base.connect("element_toggle",self,"_on_new_trap")
	self.base.connect("element_mouse_hover",self,"set_is_ui_occupied",[true])
	self.base.connect("element_mouse_exit",self,"set_is_ui_occupied",[false])

#TODO: open a panel showing all the lure traps available for this level
func lure_btn():
	#only spawn the first lure trap for now...
	var lure = preload("res://scenes/traps/LureTrap.tscn").instance()
	lure.init(base.game,base.get_lure_tilemap(),lure,self)
	base.game.add_child(lure)
	
#TODO: open a panel showing all the misc traps available for this level
func misc_btn():
	#only spawn the first misc trap for now...
	var misc = preload("res://scenes/traps/MiscTrap.tscn").instance()
	misc.init(base.game,base.get_lure_tilemap(),misc,self)
	base.game.add_child(misc)

#when the player is using the ui interface
func set_is_ui_occupied(value):
	is_ui_occupied = value
	
func get_is_ui_occupied():
	return is_ui_occupied

#this will prevent the player from choosing two traps at the same time
func _on_new_trap():
	emit_signal("new_trap")
	
