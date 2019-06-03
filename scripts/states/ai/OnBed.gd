extends Node

"""
	Teenager OnBed state
"""

signal finished
signal entered

var base
var bed = null
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
	self.teen.animations[teen.id]['OnBed'][teen.facing_direction]['flip'] = false
	self.teen.animations[teen.id]['OnBedReading'][teen.facing_direction]['flip'] = false
	
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
		var _custom = Node.new()
		_custom.name = 'OnBedReading'
		
		base.teenager.state_animation = false
		base.teenager.custom_animation = _custom
		base.teenager.kinematic_teenager.global_position = bed.global_position
		
		if base.state_timer.is_stopped():
			base.state_timer.set_wait_time(duration)
		
	else:
		#wait for him to reach the bed before continuing
		if not base.state_timer.is_stopped():
			base.state_timer.stop()
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	base.teenager.custom_animation = null
	bed = null
	base.disconnect("timer_finished",self,"exit")
	emit_signal("finished")