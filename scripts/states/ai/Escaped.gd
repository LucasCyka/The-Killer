extends Node

"""
	Teenager escaped state
	
	This is a point-of-no-return state.
"""

signal finished
signal entered

var game
var base
var modulate
var escape_object

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	self.modulate = base.teenager.get_modulate()
	self.base.teenager.set_z_index(20)
	emit_signal("entered")
	
	game = base.teenager.get_parent().get_parent()
	if game.get_current_mode() != game.MODE.GAMEOVER: 
		#the player lost the game here
		game.set_current_mode(game.MODE.GAMEOVER)
	
	self.escape_object = game.get_escape_object(base.teenager.global_position)
	
func update(delta):
	#fade the teen/escape objects
	modulate = base.teenager.get_modulate()
	
	if modulate.a > 0:
		modulate = Color(1,1,1,modulate.a-0.002)
		base.teenager.set_modulate(modulate)
	
	if escape_object.get_modulate().a > 0:
		escape_object.set_modulate(Color(1,1,1,escape_object.get_modulate().a-0.002))
	
	
#destructor
func exit():
	emit_signal("finished")