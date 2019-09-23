extends Control

"""
	Base class for the all the user interface elements in the game.
"""

signal element_toggle
signal element_mouse_hover
signal element_mouse_exit
signal element_changed_focus

#UI elements
var teenager_panel = null
var traps_ui = null
var misc_ui = null
var info_ui = null
var gameover_ui = null
var mouse_ui = null
var winning_ui = null
var pause_ui = null
var game = null

#only initialize the UI when the game is fully loaded
func _ready():
	game = get_parent()
	game.connect("loaded",self,"init")

#instantiate and initialize ui elements
func init():
	teenager_panel = get_node("Canvas/TeenagerInfo")
	traps_ui = get_node("Canvas/TrapsUI")
	misc_ui = get_node("Canvas/MiscUI")
	info_ui = get_node("Canvas/InfoUI")
	gameover_ui = get_node("Canvas/GameOverUI")
	mouse_ui = get_node("Canvas/MouseUI")
	winning_ui = get_node("Canvas/WinningUI")
	pause_ui = get_node("Canvas/PauseMenu")
	
	teenager_panel.init(self)
	traps_ui.init(self)
	misc_ui.init(self)
	info_ui.init(self)
	gameover_ui.init(self)
	mouse_ui.init(self)
	winning_ui.init(self)
	pause_ui.init(self)
	
	#detect when a element in the ui is used and hovered
	var buttons = get_buttons()
	for button in buttons:
		button.connect("pressed",self,"_on_toggle")
		button.connect("mouse_entered",self,"_on_hover")
		button.connect("mouse_exited",self,"_on_exit")

#return an array containing selection buttons for each teenager
func get_teenagers_buttons():
	var teenagers = []

	for teenager in game.get_teenagers():
		teenagers.append(teenager.get_node("TeenagerButton"))
		
	return teenagers

#return the tilemap where lure traps can be build
func get_lure_tilemap():
	return game.get_floor_tile()
	#TODO: return instead the A* tilemap

func get_bump_tilemap():
	return game.get_wall_tile()

#return all the buttons used in the ui
func get_buttons():
	var buttons = traps_ui.get_child(0).get_children() 
	buttons = buttons + traps_ui.get_child(1).get_child(0).get_children()
	buttons = buttons + misc_ui.get_child(0).get_children()
	buttons = buttons + info_ui.get_child(1).get_children()
	
	for element in buttons:
		if !element is TextureButton:
			buttons.erase(element) #this can cause an error in the loop, idk...
	
	return buttons

#get traps that are actually selected by the player
func get_selected_traps():
	#all traps in the world 
	var traps = get_tree().get_nodes_in_group("Lure")
	traps = traps + get_tree().get_nodes_in_group("Misc")
	traps = traps + get_tree().get_nodes_in_group("Vice")
	
	#traps not placed/current selected by the player
	var selected_traps = []
	
	for trap in traps:
		if not trap.is_placed:
			selected_traps.append(trap)
	
	return selected_traps
	
#lock all elements in the user interface
func lock():
	#lock buttons
	for btn in get_buttons():
		if btn is TextureButton:
			btn.set_disabled(true)
		
#unlock all elements of the user interface
func unlock():
	#unlock buttons
	for btn in get_buttons():
		if btn is TextureButton:
			btn.set_disabled(false)

#play a animation of a texture button
func play_button_animation(btn,speed=1):
	$Canvas/Animations/BtnAnims.play(btn,-1,speed)

#an animation that is played when the teen is transformed into a death
#trap.
func play_death_trap_anim(teen_spr,pos):
	play_button_animation('MiscBtn',1.2)
	var teen_text = $Canvas/Animations/DeathTrapAnim/TeenSpr
	var death_anim = $Canvas/Animations/DeathTrapAnim
	
	teen_text.texture = teen_spr
	teen_text.show()
	teen_text.global_position = pos.origin
	
	#setup and start teen anim
	death_anim.get_animation('misc').track_insert_key(0,0,pos.origin)
	death_anim.play("misc",-1,2)
	
	#play sound effect
	game.audio_system.play_sound('Taking')

#play an animation on a label
func play_label_animation(label):
	$Canvas/Animations/LabelAnims.play(label)

#animation of score points
func play_score_animation(p_pos,text):
	var label = preload('res://scenes/FlyingLabel2.tscn').instance()
	label.get_child(0).init(text,p_pos,Vector2(109.809,21.886))
	$Canvas/Animations.add_child(label)

#this signal is emmited when a new element in the user interface is used
func _on_toggle():
	emit_signal("element_toggle")

#this signal is emmited when an element in the ui is being hover
func _on_hover():
	emit_signal("element_mouse_hover")

func _on_exit():
	emit_signal("element_mouse_exit")





