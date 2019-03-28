extends Node

"""
	Teenager OnVice state

	Stage 0: look at the trap for some time.
	Stage 1: consume the trap and free it.
	Stage 2  quit state
"""

signal finished
signal entered

var base
var consuming_time
var stage = 0
var current_trap = 0
var _timer = null

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.current_trap = base.teenager.current_trap
	self.base.is_forced_state = false
	self.consuming_time = state_time
	#base.connect("timer_finished",self,"exit")
	
	#start the stage sequences
	_timer = Timer.new()
	_timer.set_wait_time(consuming_time/2)
	_timer.name = "_Timer"
	base.add_child(_timer)
	_timer.connect("timeout",self,"next_stage")
	_timer.start()
	
	emit_signal("entered")
	
func update(delta):
	pass
	
func exit():
	if _timer != null:
		#something cut this routine early than expected, do not restart the routine
		_timer.disconnect("timeout",self,"next_stage")
		_timer.queue_free()
		_timer = null
		stage = 0
		current_trap = 0
		if base.is_forced_state:
			base._on_routine = false
		else: base._on_routine = true
		emit_signal("finished")
	else:
		#just go back to the routine
		#_timer.disconnect("timeout",self,"next_stage")
		#_timer.queue_free()
		#_timer = null
		stage = 0
		current_trap = 0
		if base.is_forced_state:
			base._on_routine = false
		else: base._on_routine = true
		emit_signal("finished")
		
	
func next_stage():
	stage += 1 
	if stage == 1:
		#apply each effect of the trap
		for effect in base.teenager.get_traps()[current_trap].effects[base.teenager.get_traps()[current_trap].id]:
			effect.call_func(base.teenager)
		base.teenager.remove_trap(base.teenager.get_traps()[current_trap],true)
		#base.teenager.get_traps()[current_trap].queue_free()
		#base.teenager.traps = []
	elif stage == 2:
		_timer.disconnect("timeout",self,"next_stage")
		_timer.queue_free()
		_timer = null
		exit()
