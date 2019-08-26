extends Node

"""
	Teenager talking state
"""

signal finished
signal entered

var base
var position
var duration
var current_target
var teenagers = []

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.custom_animation = base.get_node('Idle')
	self.base.connect("timer_finished",self,"exit")
	self.position = state_position
	self.duration = state_time
	self.teenagers = get_tree().get_nodes_in_group("AI")
	emit_signal("entered")
	
func update(delta):
	if base == null or teenagers == []:
		return
	
	#only continue this state if he's on the right position
	if self.position.distance_to(base.teenager.kinematic_teenager.global_position) > 20:
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
		base.teenager.state_animation = false
		base.teenager.custom_animation = null
		if base.teenager.walk(self.position):#fix a weird bug
			base.teenager.global_position = star.get_closest_tile(base.teenager.global_position)
		base.teenager.is_talking = false
	else:
		if base.state_timer.is_stopped():
			base.state_timer.set_wait_time(duration)
			base.state_timer.start()
		
		#search for teenagers to tallk
		if current_target == null:
			#TODO: waiting anims instead
			base.teenager.is_talking = false
			base.teenager.custom_animation = base.get_node('Idle')
			for teen in teenagers:
				if teen == base.teenager: continue
				if not teen.is_object_visible(base.teenager.detection_area): continue
				
				var teen_pos = teen.kinematic_teenager.global_position
				var distance = teen_pos.distance_to(base.teenager.kinematic_teenager.global_position)
				
				if distance < 100:
					current_target = teen
					break
		else:
			#check if the teenager still close
			var distance = current_target.kinematic_teenager.global_position.distance_to(base.teenager.kinematic_teenager.global_position)
			if distance >100:
				current_target = null
			else:
				#turn to who he's talking
				var dir = current_target.kinematic_teenager.global_position
				dir = dir - base.teenager.kinematic_teenager.global_position
				dir = dir.normalized()
				dir = dir.round()
				
				#for some reason godot is returning '-0' sometimes... why?
				if dir.x == -0: dir.x = 0
				if dir.y == -0: dir.y = 0
				
				#prevent from look at diagonals, since there are not diagonal
				#animations yet.
				if not abs(dir.x) == abs(dir.y):
					base.teenager.facing_direction = dir
				
				if base.teenager.is_talkative:
					#activate talking animations
					base.teenager.custom_animation = null
					base.teenager.state_animation = true
					base.teenager.is_talking = true
					

func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	base.teenager.is_talking = false
	base.teenager.custom_animation = null
	current_target = null
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")