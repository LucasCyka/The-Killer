extends Control

"""
	Miscellaneous  elements of the user interface
"""

signal new_misc

var base = null

#constructor
func init(base):
	self.base = base
	self.base.connect("element_toggle",self,"_on_new_misc")

#hunt button pressed state
func hunt():
	#check if the game can change to the hunting mode before spawning
	#the hunter.
	if base.game.get_current_mode() == base.game.MODE.GAMEOVER:
		return
		 
	var hunter = preload("res://scenes/PlayerHunter.tscn").instance()
	hunter.init(base.game,base)
	base.game.get_node("AI").add_child(hunter)
	 
func _on_new_misc():
	emit_signal("new_misc")