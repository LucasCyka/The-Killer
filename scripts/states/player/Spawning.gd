extends Node

"""
	Player spawning state
"""

signal finished

var base
var is_spawn = false setget set_is_spawn

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.connect("timer_finished",self,"set_is_spawn",[true])
	
	set_process_input(true)
	
func update(delta):
	pass

func input(event):
	if Input.is_action_just_pressed("cancel_input"):
		transitions()

#detect transitions between states
func transitions():
	### SPAWNING TO DEPLOYMENT ###
	if !is_spawn:
		base.stack.append(base.get_node("Deployment"))
		exit()
	### SPAWNING TO IDLE ###
	else:
		base.stack.append(base.get_node("EndingSpawn"))
		exit()
		
#when the player spawned in the area
func set_is_spawn(value):
	is_spawn = value
	
	if is_spawn:
		transitions()
		
#destructor
func exit():
	if base.is_connected("timer_finished",self,"set_is_spawn"):
		base.disconnect("timer_finished",self,"set_is_spawn")
	set_process_input(false)
	emit_signal("finished")
