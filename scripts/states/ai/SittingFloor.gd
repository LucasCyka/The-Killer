extends Node

"""
	Teenager sitting on floor state
"""

signal finished
signal entered

var base
var teen
var position
var duration

func init(base,state_position,state_time):
	self.base = base
	self.teen = base.teenager
	self.position = state_position
	self.duration = state_time
	self.teen.state_animation = false
	self.base.connect("timer_finished",self,"exit")
	emit_signal("entered")
	
func update(delta):
	if base == null:return
	
	#check if the teen is close enough to the place he will sit
	if teen.walk(position):
		#change the anim
		teen.state_animation = true
		#teen.kinematic_teenager.global_position = position
		
		if base.state_timer.is_stopped():
			base.state_timer.set_wait_time(duration)
	else:
		#wait for him to reach the location before continuing
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	self.base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")