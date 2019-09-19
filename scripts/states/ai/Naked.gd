extends Node

"""
	Teenager naked state
"""

signal finished
signal entered

var base
var duration
var position
var teenagers
var game
var saw_by = [] #teens who saw this one naked

func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	self.duration = state_time
	self.position = state_position
	self.game = base.teenager.get_parent().get_parent()
	self.teenagers = game.get_teenagers_by_trait(base.teenager.TRAITS.NERD)
	base.connect("timer_finished",self,"exit")
	
	emit_signal("entered")
	
func update(delta):
	if base == null:
		return
	
	#only continue this state if he's on the right position
	if self.position.distance_to(base.teenager.get_position()) > 20:
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
		base.teenager.state_animation = false
		base.teenager.walk(self.position)
	else:
		if base.state_timer.is_stopped():
			base.teenager.state_animation = true
			base.state_timer.set_wait_time(duration)
			base.state_timer.start()
			
		if teenagers == []: return
		
		#cripple some teenagers
		for teen in teenagers:
			var weak_ref = weakref(teen)
			if weak_ref.get_ref() == null: return
			
			if teen.get_position().distance_to(base.teenager.get_position()) < 120:
				if saw_by.find(teen) == -1:
					saw_by.append(teen)
					teen.state_machine.force_state('Crippled')
					self.game.audio_system.play_2d_sound('Falling',teen.get_position())
			
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	teenagers = null
	if base.is_connected("timer_finished",self,"exit"):
		base.disconnect("timer_finished",self,"exit")
	
	emit_signal("finished")









