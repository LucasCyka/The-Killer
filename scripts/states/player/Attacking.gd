extends Node

"""
	Hunter attacking state
"""

signal finished

var base
var target
var target_pos
var player_pos
var new_position = Vector2(-500,-500)

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.target = base.player.target
	self.target_pos = self.target.kinematic_teenager.global_position
	self.player_pos = self.base.player.kinematic_player.global_position
	
func update(delta):
	#update positions
	target_pos = self.target.kinematic_teenager.global_position
	player_pos = self.base.player.kinematic_player.global_position
	
	#check if the player is close enough to the teenager then attack
	if target_pos.distance_to(player_pos) > 35:
		base.player.walk(target_pos)
	else:
		base.player.attack(target)
	
	transitions()
	
func input(event):
	if Input.is_action_just_pressed("ok_input"):
		new_position = base.player.mouse_position

#detect transitions between states
func transitions():
	if base.player.target == null:
		if new_position != Vector2(-500,-500):
		### ATTACKING TO MOVING ###
			base.stack.append(base.get_node("Moving"))
			base.state_position = new_position
			exit()
		else:
		### ATTACKING TO IDLE ###
			base.stack.append(base.get_node("Idle"))
			exit()
	
#destructor
func exit():
	emit_signal("finished")
	
