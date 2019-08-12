extends Node

"""
	Hunter Moving state
"""

signal finished

var base
var target

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.target = state_position
	
func update(delta):
	#move to the target
	if base.player.walk(target):
		transitions()
	
	#check if he wants to attack someone
	if base.player.target != null:
		transitions()
	
func input(event):
	if Input.is_action_just_pressed("ok_input"):
		target = base.player.mouse_position
	
#detect transitions between states
func transitions():
	### MOVING TO IDLE ###
	if base.player.target == null:
		base.stack.append(base.get_node("Idle"))
		exit()
	## MOVING TO ATTACKING ##
	else:
		if base.player.target.is_immune: return 
		
		base.stack.append(base.get_node("Attacking"))
		base.state_position = base.player.target.kinematic_teenager.global_position
		exit()

#destructor
func exit():
	emit_signal("finished")