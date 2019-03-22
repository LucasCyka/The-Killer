extends Control

"""
	This UI element will control the placement/selection of traps.
"""

signal new_trap

var base = null
var is_ui_occupied = false setget set_is_ui_occupied
var traps_data = {}

#world nodes
onready var selection_panel = $TrapsSelection

#constructor
func init(base):
	self.base = base
	self.base.connect("element_toggle",self,"_on_new_trap")
	self.base.connect("element_mouse_hover",self,"set_is_ui_occupied",[true])
	self.base.connect("element_mouse_exit",self,"set_is_ui_occupied",[false])
	
	load_trap_info()
	
#TODO: open a panel showing all the lure traps available for this level
func lure_btn():
	selection_panel.show()
	#only spawn the first lure trap for now...
	#var lure = preload("res://scenes/traps/LureTrap.tscn").instance()
	#lure.init(base.game,base.get_lure_tilemap(),lure,self)
	#base.game.add_child(lure)
	
#TODO: open a panel showing all the misc traps available for this level
func misc_btn():
	#only spawn the first misc trap for now...
	var misc = preload("res://scenes/traps/MiscTrap.tscn").instance()
	misc.init(base.game,base.get_lure_tilemap(),misc,self)
	base.game.add_child(misc)

#TODO: open a panel showing all the vice traps available for this level
func vice_btn():
	#only spawn the first misc trap for now...
	var vice = preload("res://scenes/traps/ViceTrap.tscn").instance()
	vice.init(base.game,base.get_lure_tilemap(),vice,self)
	base.game.add_child(vice)

#TODO: open a panel showing all the bump traps available for this level
func bump_btn():
	var bump = preload("res://scenes/traps/BumpTrap.tscn").instance()
	bump.init(base.game,base.get_bump_tilemap(),bump,self)
	base.game.add_child(bump)

#when the player is using the ui interface
func set_is_ui_occupied(value):
	is_ui_occupied = value
	
func get_is_ui_occupied():
	return is_ui_occupied

#this will prevent the player from choosing two traps at the same time
func _on_new_trap():
	emit_signal("new_trap")

#loads data from all traps available in this level
func load_trap_info():
	var traps = {} #traps.json 
	var traps_in_level = {} #traps_by_level.json
	
	var file = File.new()
	file.open("res://resources/json/traps.json",File.READ)
	traps = file.get_as_text()
	traps = parse_json(traps)
	
	pass







