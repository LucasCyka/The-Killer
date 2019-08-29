extends Node

"""
	Hunter Idle state
"""

signal finished

var base
var game

#constructor
func init(base,state_position,state_time):
	self.base = base
#	self.base.player.is_deployed = true
	self.game = base.player.game
	
	#hunting mode
	if self.game.get_current_mode() != game.MODE.HUNTING and !base.player.exiting:
		if self.game.get_current_mode() == game.MODE.WON: return
		if self.game.get_current_mode() == game.MODE.GAMEOVER: return
		self.game.set_current_mode(game.MODE.HUNTING)
	
func update(delta):
	if base.player.target != null:
		transitions()

func input(event):
	if Input.is_action_just_pressed("ok_input"):
		transitions()
		#TODO: check if he's not attacking someone in range

#detect transitions between states
func transitions():
	### IDLE TO MOVING ###
	if base.player.target == null:
		base.stack.append(base.get_node("Moving"))
		base.state_position = base.player.mouse_position
		exit()
		
	else:
	### IDLE TO ATTACKING ###
		if base.player.target.is_immune: return 
		
		base.stack.append(base.get_node("Attacking"))
		base.state_position = base.player.target.kinematic_teenager.global_position
		exit()

func exit():
	emit_signal("finished")