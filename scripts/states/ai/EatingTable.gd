extends Node

"""
	Teenager Eating on the table state
"""

signal finished
signal entered

var base
var duration
var table
var teen

func init(base,state_position,state_time):
	self.base = base
	self.teen = base.teenager
	self.duration = state_time
	self.teen.state_animation = false
	self.base.connect("timer_finished",self,"exit")
	emit_signal("entered")
	
func update(delta):
	if base == null: return
	
	#prevents wrong filiping
	self.teen.animations[teen.id]['EatingTable'][teen.facing_direction]['flip'] = false
	
	if table == null:
		#search for a bed this teenager owns
		var found = false
		for object in get_tree().get_nodes_in_group("Object"):
			if object.type == object.TYPE.TABLE:
				if object.owner_id == base.teenager.id or object.owner_id_2 == base.teenager.id:
					found = true
					table = object
					break
		
		if not found: 
			exit() #theres no bed, exit this state
			return
	
	#check if the teen is close enough to the bed
	if base.teenager.walk(table.global_position):
		#change the anim and position
		base.teenager.state_animation = true
		base.teenager.kinematic_teenager.global_position = table.global_position
		
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
	table = null
	self.base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")