extends Node

"""
	Teenager InLove state
"""

signal finished
signal entered

var base
var teenager
var lover
var lover_point
var found_lover = false
var timer = null
var timer_started = false
var finished = false

const duration = 60

func init(base,state_position,state_time):
	self.base = base
	self.base.is_forced_state = false
	self.teenager = self.base.teenager
	self.teenager.state_animation = false
	self.lover = self.teenager.lover
	self.base.state_timer.stop()
	timer = preload('res://scenes/CustomTimer.tscn').instance()
	add_child(timer)
	timer.stop()
	timer.one_shot = true
	timer.connect('timeout',self,'exit')
	timer.set_wait_time(duration)
	
	emit_signal("entered")
	
func update(delta):
	if base == null or finished:
		return
		
	if lover.global_position.distance_to(teenager.global_position) >20 and !found_lover:
		#walk towards the lover
		teenager.walk(lover.global_position)
	elif lover.state_machine.get_current_state() != 'InLove' and !found_lover:
		found_lover = true
		#check if his lover can go to the woods with him
		if lover.state_machine.check_forced_state('InLove'):
			lover.state_machine.force_state('InLove')
		else: exit()
	elif lover_point == null:
		#search the closest lover point
		lover_point = teenager.get_parent().get_parent().get_love_point(teenager.global_position)
		lover.state_machine.get_node('InLove').lover_point = lover_point
		
	elif lover_point.distance_to(teenager.global_position) > 20:
		#walk towards the lover point
		teenager.walk(lover_point)
	else:
		if timer != null:
			if timer.is_stopped() and !timer_started:
				timer_started = true
				finished = true
				timer.start()
		#put him on the lover point.
		#start anims.
		#wait for it to end.
		#teenager.global_position = lover_point


func exit():
	timer.disconnect('timeout',self,'exit')
	timer.call_deferred('free')
	timer = null
	found_lover = false
	lover_point = null
	timer_started = false
	
	#if finished:
	#	base._on_routine = true
	#elif base.i:
	#	base._on_routine = false
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	
	emit_signal("finished")
	finished = false

	
	