extends Control

"""
	This UI element will control the placement of traps.
"""

var base = null

#constructor
func init(base):
	self.base = base

#TODO: open a panel showing all the lure traps available for this level
func lure_btn():
	#only spawn the first lure trap for now...
	var lure = preload("res://scenes/traps/LureTrap.tscn").instance()
	lure.init(base.game,base.get_lure_tilemap(),lure)
	base.game.add_child(lure)