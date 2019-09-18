extends Node

"""
	Teenager sleeping state
"""

signal finished
signal entered

var base
var teen
var duration
var bed
var game
var game_time
var slept = false
var finished = false
var wake_time

func init(base,state_position,state_time):
	self.base = base
	self.teen = base.teenager
	self.game = base.teenager.get_parent().get_parent()
	self.wake_time = teen.wake_time
	slept = false
	finished = false
	#self.duration = teen.remaining_sleep_time
	#self.base.state_timer.stop()
	#self.base.state_timer.set_wait_time(duration)
	#self.base.connect("timer_finished",self,"exit")
	#self.base.state_timer.start()
	self.teen.state_animation = false
	emit_signal("entered")
	
func update(delta):
	if base == null: return
	self.game_time = game.get_time()
	
	#prevent the teen from lying on the wrong side of the bed
	if bed != null:
		if not bed.is_flipped_h():
			self.teen.animations[teen.id]['Sleeping'][teen.facing_direction]['flip'] = false
		else:
			self.teen.animations[teen.id]['Sleeping'][teen.facing_direction]['flip'] = true
		
	if bed == null:
		#search for a bed this teenager owns
		var found = false
		for object in get_tree().get_nodes_in_group("Object"):
			if object.type == object.TYPE.BED:
				if object.owner_id == base.teenager.id or object.owner_id_2 == base.teenager.id:
					found = true
					bed = object
					break
		
		if not found: 
			exit() #theres no bed, exit this state
			return
	
	#check if the teen is close enough to the bed
	if base.teenager.walk(bed.global_position):
		#change the anim and position
		base.teenager.state_animation = true
		base.teenager.kinematic_teenager.global_position = bed.global_position
		
		#if base.state_timer.is_stopped():
		#	base.state_timer.set_wait_time(duration)
		#	base.state_timer.start()
	
	#check if it's time to wake up
	if not finished:
		if (game_time/60) == (wake_time/60):
			slept = true
			exit()
	
	#else:
		#wait for him to reach the bed before continuing
	#	if not base.state_timer.is_stopped():
	#		base.state_timer.stop()
			
	#if not base.state_timer.is_stopped() and teen.remaining_sleep_time>2:
	#	teen.remaining_sleep_time = base.state_timer.time_left
	
func exit():
	finished = true
	if not slept:
		base._on_routine = false
	else:
		teen.last_routine = 0
		base.is_forced_state = false
		base._on_routine = true
		teen.is_tired = false
	#self.base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")