extends Node

"""
	Teenager Fishing state
"""

signal finished
signal entered

var base
var duration
var teen
var position

#initialize
func init(base,state_position,state_time):
	self.base = base
	self.duration = state_time
	self.position = state_position
	self.teen = base.teenager
	self.teen.state_animation = false
	self.base.connect("timer_finished",self,"exit")
	emit_signal("entered")
	
func update(delta):
	if base == null:
		return
	
	#check if the teen is close enough to the place he will sit
	if teen.walk(position):
		#change the anim
		teen.state_animation = true
		#teen.kinematic_teenager.global_position = position
		#custom balloons over the player's head
		self.teen.is_talking = false
		self.teen.is_thinking = true
		self.teen.custom_balloons = ['fish','fish2','bait','love']
		if base.state_timer.is_stopped():
			base.state_timer.set_wait_time(duration)
			base.state_timer.start()
	else:
		#wait for him to reach the location before continuing
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	self.teen.is_thinking = false
	self.teen.custom_balloons = []
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")