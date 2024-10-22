extends Control

"""
	This UI element will control the placement/selection of traps.
"""

signal new_trap

var base = null
var is_ui_occupied = false setget set_is_ui_occupied
var selection_page = 1
var selected_trap = false
var last_selected_category = ""

#world nodes
onready var selection_panel = $TrapsSelection
onready var trap_category = $TrapsSelection/TrapsCategory
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
	self.base.connect("element_changed_focus",self,"close_selection")
	
	#loads trap data
	bump = base.game.get_traps(trap_enum.BUMP)
	lure = base.game.get_traps(trap_enum.LURE)
	misc = base.game.get_traps(trap_enum.MISC)
	vice = base.game.get_traps(trap_enum.VICE)

#close the selection panel
func _input(event):
	if Input.is_action_just_pressed("cancel_input"):
		if selection_panel.is_visible():
			close_selection()
		elif selected_trap and base.game.get_current_mode() != base.game.MODE.HUNTING:
			trap_category.text = last_selected_category
			selection_panel.show()

#open a panel showing all the lure traps available for this level
func lure_btn():
	#sound effect
	base.game.audio_system.play_sound('Click2')
	
	if trap_category.text == "LURES":
		#the panel for this trap is already open, close it.
		close_selection()
		return
	
	trap_category.text = "LURES"
	fill_grid(lure,trap_enum.LURE)
	show_selection($TrapsPanel/LureBtn.get_rect().position)
	
#open a panel showing all the misc traps available for this level
func misc_btn():
	#sound effect
	base.game.audio_system.play_sound('Click2')
	
	if trap_category.text == "MISC.":
		#the panel for this trap is already open, close it.
		close_selection()
		return
	
	trap_category.text = "MISC."
	fill_grid(misc,trap_enum.MISC)
	show_selection($TrapsPanel/MiscBtn.get_rect().position)

#open a panel showing all the vice traps available for this level
func vice_btn():
	#sound effect
	base.game.audio_system.play_sound('Click2')
	
	if trap_category.text == "VICES":
		#the panel for this trap is already open, close it.
		close_selection()
		return
	
	trap_category.text = "VICES"
	fill_grid(vice,trap_enum.VICE)
	show_selection($TrapsPanel/ViceBtn.get_rect().position)

#open a panel showing all the bump traps available for this level
func bump_btn():
	#sound effect
	base.game.audio_system.play_sound('Click2')
	
	if trap_category.text == "NOISES":
		#the panel for this trap is already open, close it.
		close_selection()
		return
	
	trap_category.text = "NOISES"
	fill_grid(bump,trap_enum.BUMP)
	show_selection($TrapsPanel/BumpBtn.get_rect().position)

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
	last_selected_category = trap_category.text
	var row = 0
	clear_buttons()
	for trap in data['ID']:
		if row > (selection_page * 18)-1: 
			#only fill the buttons till a certain amount
			break
		
		if trap <0:
			#just trash, continue
			continue
		
		#trap data
		var texture = load("res://sprites/traps/" + data['Icon'][trap])
		var price = data['Price'][trap]
		var fear = data['Fear'][trap]
		var curiosity = data['Curiosity'][trap]
		var requirements = data['Requirements'][trap]
		var oneshot = data['OneShot'][trap]
		var onspot = data['OnSpot'][trap]
		var walkable = data['Walkable'][trap]
		var _name = data['Name'][trap]
		var desc = data['Desc'][trap]
		var tiles = data['Placement'][trap]
		var sound = data['Sound'][trap]
		var death_trap = null
		
		#check if this is a death trap. (death traps have the teen's anims)
		if data.keys().find('DeathTrap') != -1:
			death_trap = data['DeathTrap'][trap]
		
		#button's texture
		buttons[row].texture_normal = texture
		
		#signals
		buttons[row].connect("pressed",self,"add_trap",[price,type,trap,fear,curiosity,
		requirements,oneshot,onspot,walkable,_name,desc,death_trap,tiles,sound])
		
		buttons[row].connect("mouse_entered",self,"show_trap_info",[_name,desc,price,fear,curiosity])
		buttons[row].connect("mouse_exited",self,"hide_trap_info")
		
		row += 1 

#check if the player has the points to 'buy' a given trap, if so, then
#instantiate it.
func add_trap(price,type,id,fear,curiosity,requirements,oneshot,onspot,walkable,
_name,desc,death_trap,tiles,sound):
	#check the price before adding the trap
	if price > base.game.get_points():
		#not enough points
		return
	
	#pass all the parameters for the trap
	match type:
		trap_enum.BUMP:
			
			var bump = preload("res://scenes/traps/BumpTrap.tscn").instance()
			bump.init(id,base.game,tiles,bump,self,
			curiosity,fear,requirements,oneshot,onspot,price,walkable,_name,desc,
			death_trap,sound)
			base.game.add_child(bump)
			
		trap_enum.LURE:
			
			var lure = preload("res://scenes/traps/LureTrap.tscn").instance()
			lure.init(id,base.game,tiles,lure,self,
			curiosity,fear,requirements,oneshot,onspot,price,walkable,_name,desc,
			death_trap,sound)
			base.game.add_child(lure)
			
		trap_enum.MISC:
			
			var misc = preload("res://scenes/traps/MiscTrap.tscn").instance()
			misc.init(id,base.game,tiles,misc,self,
			curiosity,fear,requirements,oneshot,onspot,price,walkable,_name,desc,
			death_trap,sound)
			base.game.add_child(misc)
			
		trap_enum.VICE:
			var vice = preload("res://scenes/traps/ViceTrap.tscn").instance()
			vice.init(id,base.game,tiles,vice,self,
			curiosity,fear,requirements,oneshot,onspot,price,walkable,_name,desc,
			death_trap,sound)
			base.game.add_child(vice)
		
	selection_panel.hide()
	hide_trap_info()
	trap_category.text = ""
	set_is_ui_occupied(false)
	selected_trap = true

#enable the selection panel
func show_selection(btn_pos):
	$TrapsSelection.show()
	#$TrapsSelection.rect_position = Vector2(btn_pos.x,$TrapsSelection.rect_position.y)

#show information about the trap being hovered
func show_trap_info(_name,desc,price,fear,curiosity):
	$TrapsSelection/Info.show()
	$TrapsSelection/Info/Name.text = _name
	$TrapsSelection/Info/Description.text = desc
	$TrapsSelection/Info/Price.text = "Price: $ "+ str(price)
	#formatting price
	if fmod(1000,price):
		$TrapsSelection/Info/Price.text = $TrapsSelection/Info/Price.text.insert($TrapsSelection/Info/Price.text.length()-3,',')
	
	#modifiers
	$TrapsSelection/Info2.show()
	var f = float(fear)/float(100)
	var c = float(curiosity)/float(100)
	f = round(lerp(1,7,f))
	c = round(lerp(1,7,c))
	
	$TrapsSelection/Info2/Fear.text = "Fear:"
	$TrapsSelection/Info2/Curiosity.text = "Cur.:"
	
	for plus in range(f):
		var txt = $TrapsSelection/Info2/Fear.text
		txt = txt.insert(txt.length(),'+')
		$TrapsSelection/Info2/Fear.text = txt
	
	for plus in range(c):
		var txt = $TrapsSelection/Info2/Curiosity.text
		txt = txt.insert(txt.length(),'+')
		$TrapsSelection/Info2/Curiosity.text = txt
	
func hide_trap_info():
	$TrapsSelection/Info.hide()
	$TrapsSelection/Info2.hide()

#disable the selection panel
func close_selection():
	$TrapsSelection.hide()
	$TrapsSelection/Info.hide()
	clear_buttons()
	hide_trap_info()
	selected_trap = false
	trap_category.text = ""
	
#clear buttons/remove signals
func clear_buttons():
	var buttons = selection_panel.get_node("GridSlots").get_children()
	for btn in buttons:
		btn.texture_normal = null
		if btn.is_connected("pressed",self,"add_trap"):
			btn.disconnect("pressed",self,"add_trap")
		if btn.is_connected("mouse_entered",self,"show_trap_info"):
			btn.disconnect("mouse_entered",self,"show_trap_info")
			btn.disconnect("mouse_exited",self,"hide_trap_info")
			