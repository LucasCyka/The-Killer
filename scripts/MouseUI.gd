extends Control

"""
	Manage mouse icons according to several states on the game.
"""

var base = null

onready var mouse = $MouseAnims

#TODO: the code below will only work for the machete icon for now. 
#Change if later for a more complex system.

#initialize
func init(base):
	self.base = base
	
	#connect hovering signal
	for teenager_btn in base.get_teenagers_buttons():
		teenager_btn.connect("mouse_entered",self,"show_machete",[true])
		teenager_btn.connect("mouse_exited",self,"show_machete",[false])

#move the "fake" mouse
func _process(delta):
	mouse.global_position = get_global_mouse_position()

#a machete is show when the player is on hunting mode and hovering a teen
func show_machete(show):
	if show:
		#only do this when the game is on HUNTING MODE
		if base.game.get_current_mode() != base.game.MODE.HUNTING:
			return
		
		mouse.show()
		mouse.play('Machete')
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse.hide()





