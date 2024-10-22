extends Control

"""
	Miscellaneous elements of the user interface
"""

signal new_misc

onready var object_panel = $ObjectPanel

var base = null
var current_object = null

#constructor
func init(base):
	self.base = base
	self.base.connect("element_toggle",self,"_on_new_misc")
	
	#link all world objects to the object panel
	var objects = get_tree().get_nodes_in_group("Object")
	for obj in objects:
		#only if they are pickable
		if obj.is_activable:
			obj.get_node("Button").connect("pressed",self,"show_object_panel",[obj])
			

#hunt button pressed state
func hunt():
	#check if the game can change to the hunting mode before spawning
	#the hunter.
	if base.game.get_current_mode() == base.game.MODE.GAMEOVER:
		return
	
	if get_tree().get_nodes_in_group('Player').size() != 0 :
		get_tree().get_nodes_in_group('Player')[0].call_deferred('free')
		return
	
	var hunter = preload("res://scenes/PlayerHunter.tscn").instance()
	hunter.init(base.game,base)
	base.game.get_node("AI").add_child(hunter)
	
	base.emit_signal('element_changed_focus')

#super zoom btn
func zoom():
	var controller = base.game.get_player_controller()
	controller.set_super_zoom(!controller.super_zoom)

#the object panel shows iformation about a object the player selected
func show_object_panel(obj):
	#don't select objects when the player is hunting
	if base.game.get_current_mode() != base.game.MODE.PLANNING:
		return
	if obj.activated:
		return
		
	#also don't select objects when the player is putting traps on the world
	if base.get_selected_traps().size() > 0:
		return
	
	#this will close panels or other elements
	base.emit_signal('element_toggle')
	base.emit_signal('element_changed_focus')
	
	#replaces '[' by the price
	var price = obj.price
	var price_text = "$" + str(price)
	var desc = obj.obj_desc
	
	if fmod(1000,price) or price == 1000:
		price_text = price_text.insert(price_text.length()-3,',')
	desc = desc.replace('[',price_text)
	
	$ObjectPanel/Object/Desc.text = desc
	
	
	if not $ObjectPanel.is_visible():
		object_panel.show()
		$ObjectPanel/Object/CancelBtn.connect('pressed',self,'hide_object_panel')
		
	current_object = obj

func hide_object_panel():
	$ObjectPanel/Object/CancelBtn.disconnect('pressed',self,'hide_object_panel')
	object_panel.hide()
	current_object = null
	
func activate_object():
	#TODO: sound effect
	#TODO: use money
	if current_object != null: 
		if current_object.price <= base.game.points:
			base.game.points -= current_object.price
			current_object.activate()
			hide_object_panel()
	

func _on_new_misc():
	emit_signal("new_misc")