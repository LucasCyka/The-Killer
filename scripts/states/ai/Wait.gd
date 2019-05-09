extends Node

"""
	Teenager waiting state
"""

signal finished
signal entered

var base
var position 
var duration

#CONSTRUCTOR
func init(base,state_position,state_time):
	self.base = base
	self.position = state_position
	self.duration = state_time
	base.connect("timer_finished",self,"exit")
	
	emit_signal("entered")
	
func update(delta):
	if base == null:
		return
	
	#only continue this state if he's on the right position
	if self.position.distance_to(base.teenager.kinematic_teenager.global_position) > 20:
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
		base.teenager.state_animation = false
		base.teenager.walk(self.position)
	else:
		if base.state_timer.is_stopped():
			base.teenager.state_animation = true
			base.state_timer.set_wait_time(duration)
			base.state_timer.start()
			
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")