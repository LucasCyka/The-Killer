extends Node

"""
	Teenager Working state
"""

signal finished
signal entered

var base
var work_obj = null
var duration
var teen

func init(base,state_position,state_time):
	self.base = base
	self.base.connect("timer_finished",self,"exit")
	self.base.teenager.state_animation = false
	self.teen = base.teenager
	self.duration = state_time
	emit_signal("entered")
	
func update(delta):
	if base == null: return
	
	#prevent the teen from lying on the wrong side of the bed
	self.teen.animations[teen.id]['Working'][teen.facing_direction]['flip'] = false
	self.teen.animations[teen.id]['Working'][teen.facing_direction]['flip'] = false
	
	if work_obj == null:
		#search for a a work object this teenager owns
		var found = false
		for object in get_tree().get_nodes_in_group("Object"):
			if object.type == object.TYPE.WORK:
				if object.owner_id == base.teenager.id or object.owner_id_2 == base.teenager.id:
					found = true
					work_obj = object
					break
		
		if not found: 
			exit() #theres no working obj, exit this state
			return
	
	#check if the teen is close enough to the working obj
	if base.teenager.walk(work_obj.global_position):
		#change the anim and position
		base.teenager.state_animation = true
		base.teenager.kinematic_teenager.global_position = work_obj.global_position
		
		if base.state_timer.is_stopped():
			base.state_timer.set_wait_time(duration)
			base.state_timer.start()
		
	else:
		#wait for him to reach the bed before continuing
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	base.teenager.custom_animation = null
	work_obj = null
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")