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

func init(base,state_position,state_time):
	self.base = base
	self.teen = base.teenager
	self.duration = teen.remaining_sleep_time
	self.base.state_timer.stop()
	self.base.state_timer.set_wait_time(duration)
	self.base.connect("timer_finished",self,"exit")
	self.base.state_timer.start()
	self.teen.state_animation = false
	emit_signal("entered")
	
func update(delta):
	if base == null: return
	
	#prevent the teen from lying on the wrong side of the bed
	self.teen.animations[teen.id]['Sleeping'][teen.facing_direction]['flip'] = false
	
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
		
		if base.state_timer.is_stopped():
			base.state_timer.set_wait_time(duration)
			base.state_timer.start()
		
	else:
		#wait for him to reach the bed before continuing
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
			
	if not base.state_timer.is_stopped() and teen.remaining_sleep_time>2:
		teen.remaining_sleep_time = base.state_timer.time_left
	
func exit():
	if teen.remaining_sleep_time >2:
		base._on_routine = false
	else:
		teen.last_routine = 0
		base.is_forced_state = false
		base._on_routine = true
		teen.is_tired = false
	self.base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")