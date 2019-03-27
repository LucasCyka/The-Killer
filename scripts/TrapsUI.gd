extends Control

"""
	This UI element will control the placement/selection of traps.
"""

signal new_trap

var base = null
var is_ui_occupied = false setget set_is_ui_occupied
var selection_page = 1

#world nodes
onready var selection_panel = $TrapsSelection
#types of traps
onready var trap_enum = preload("res://scripts/Traps.gd").TYPES

#traps avaialbe in this level
var bump = {}
var lure = {}
var misc = {}
var vice = {}

#constructor
func init(base):
	self.base = base
	self.base.connect("element_toggle",self,"_on_new_trap")
	self.base.connect("element_mouse_hover",self,"set_is_ui_occupied",[true])
	self.base.connect("element_mouse_exit",self,"set_is_ui_occupied",[false])
	
	#loads trap data
	bump = base.game.get_traps(trap_enum.BUMP)
	lure = base.game.get_traps(trap_enum.LURE)
	misc = base.game.get_traps(trap_enum.MISC)
	vice = base.game.get_traps(trap_enum.VICE)

#close the selection panel
func _input(event):
	if Input.is_action_just_pressed("cancel_input"):
		close_selection()
	pass

#open a panel showing all the lure traps available for this level
func lure_btn():
	fill_grid(lure,trap_enum.LURE)
	show_selection($TrapsPanel/LureBtn.get_rect().position)
	
#open a panel showing all the misc traps available for this level
func misc_btn():
	fill_grid(misc,trap_enum.MISC)
	show_selection($TrapsPanel/MiscBtn.get_rect().position)
	"""
	#only spawn the first misc trap for now...
	var misc = preload("res://scenes/traps/MiscTrap.tscn").instance()
	misc.init(base.game,base.get_lure_tilemap(),misc,self)
	base.game.add_child(misc)
	"""

#open a panel showing all the vice traps available for this level
func vice_btn():
	fill_grid(vice,trap_enum.VICE)
	show_selection($TrapsPanel/ViceBtn.get_rect().position)
	"""
	#only spawn the first misc trap for now...
	var vice = preload("res://scenes/traps/ViceTrap.tscn").instance()
	vice.init(base.game,base.get_lure_tilemap(),vice,self)
	base.game.add_child(vice)
	"""

#open a panel showing all the bump traps available for this level
func bump_btn():
	fill_grid(bump,trap_enum.BUMP)
	show_selection($TrapsPanel/BumpBtn.get_rect().position)
	"""
	var bump = preload("res://scenes/traps/BumpTrap.tscn").instance()
	bump.init(base.game,base.get_bump_tilemap(),bump,self)
	base.game.add_child(bump)
	"""

#when the player is using the ui interface
func set_is_ui_occupied(value):
	is_ui_occupied = value
	
func get_is_ui_occupied():
	return is_ui_occupied

#this will prevent the player from choosing two traps at the same time
func _on_new_trap():
	emit_signal("new_trap")

#fill each button at the traps selections panel with a trap of a given type
func fill_grid(data,type):
	var buttons = selection_panel.get_node("GridSlots").get_children()
	var row = 0
	clear_buttons()
	for trap in data['ID']:
		if row > (selection_page * 9)-1: 
			#only fill the buttons till a certain amount
			break
		
		#trap data
		var texture = load("res://sprites/traps/" + data['Icon'][trap])
		var price = data['Price'][trap]
		var fear = data['Fear'][trap]
		var curiosity = data['Curiosity'][trap]
		var requirements = data['Requirements'][trap]
		
		#button's texture
		buttons[row].texture_normal = texture
		
		#signals
		buttons[row].connect("pressed",self,"add_trap",[price,type,trap,fear,curiosity,
		requirements])
		
		row += 1 

#check if the player has the points to 'buy' a given trap, if so, then
#instantiate it.
func add_trap(price,type,id,fear,curiosity,requirements):
	#TODO: check the price before adding the trap
	#TODO: pass all the parameters for the trap
	
	match type:
		trap_enum.BUMP:
			
			var bump = preload("res://scenes/traps/BumpTrap.tscn").instance()
			bump.init(id,base.game,base.get_bump_tilemap(),bump,self,curiosity,fear,requirements)
			base.game.add_child(bump)
			
		trap_enum.LURE:
			
			var lure = preload("res://scenes/traps/LureTrap.tscn").instance()
			lure.init(id,base.game,base.get_lure_tilemap(),lure,self,curiosity,fear,requirements)
			base.game.add_child(lure)
			
		trap_enum.MISC:
			
			var misc = preload("res://scenes/traps/MiscTrap.tscn").instance()
			misc.init(id,base.game,base.get_lure_tilemap(),misc,self,curiosity,fear,requirements)
			base.game.add_child(misc)
			
		trap_enum.VICE:
			var vice = preload("res://scenes/traps/ViceTrap.tscn").instance()
			vice.init(id,base.game,base.get_lure_tilemap(),vice,self,curiosity,fear,requirements)
			base.game.add_child(vice)

#enable the selection panel
func show_selection(btn_pos):
	$TrapsSelection.show()
	$TrapsSelection.rect_position = Vector2(btn_pos.x,$TrapsSelection.rect_position.y)

#disable the selection panel
func close_selection():
	$TrapsSelection.hide()
	clear_buttons()
	
#clear buttons/remove signals
func clear_buttons():
	var buttons = selection_panel.get_node("GridSlots").get_children()
	for btn in buttons:
		btn.texture_normal = null
		if btn.is_connected("pressed",self,"add_trap"):
			btn.disconnect("pressed",self,"add_trap")
		














