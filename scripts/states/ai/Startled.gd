extends Node

"""
	Teenager startled state
"""

signal finished
signal entered

var base
var bump_position

#this state is divided into 4 stages
#0: heard the sound just now, wait a bit
#1: go check the sound
#2: wait a bit if nothing happened
#3: end the state
var stage = 0
var stage_timer

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.is_forced_state = false
	self.bump_position = state_position
	
	stage_timer = Timer.new()
	stage_timer.set_wait_time(4)
	stage_timer.connect("timeout",self,"next_stage")
	base.add_child(stage_timer)
	stage_timer.start()
	
	emit_signal("entered")
	
func update(delta):
	if base == null:
		return
	
	#remove all bump traps
	for trap in base.teenager.traps:
		if trap.type == trap.TYPES.BUMP:
			base.teenager.remove_trap(trap,true)
			break
	
	#if base.teenager.traps.size() == 1:
		
	if stage == 1:
		stage_timer.stop()
		if base.teenager.walk(bump_position):
			stage_timer.start()
			stage += 1
	elif stage == 3:
		exit()

func next_stage():
	if stage != 1:
		stage += 1

#destructor
func exit():
	if stage_timer != null:
		#base.teenager.traps.remove(0)
		stage_timer.disconnect("timeout",self,"next_stage")
		stage_timer.queue_free()
		stage_timer = null
		stage = 0
		if base.is_forced_state:
			base._on_routine = false
		else: base._on_routine = true
		emit_signal("finished")