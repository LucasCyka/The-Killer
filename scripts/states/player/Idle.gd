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
	self.base.player.is_deployed = true
	self.game = base.player.game
	
	#hunting mode
	self.game.set_current_mode(game.MODE.HUNTING)
	
func update(delta):
	pass

func input(event):
	if event is InputEventMouseButton:
		if Input.is_action_just_pressed("ok_input"):
			transitions()
		#TODO: check if he's not attacking someone in range

#detect transitions between states
func transitions():
	### IDLE TO MOVING ###
	base.stack.append(base.get_node("Moving"))
	base.state_position = base.player.mouse_position
	exit()

func exit():
	emit_signal("finished")