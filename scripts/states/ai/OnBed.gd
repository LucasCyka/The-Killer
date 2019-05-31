extends Node

"""
	Teenager OnBed state
"""

signal finished
signal entered

var base
var bed = null

func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	emit_signal("entered")
	
func update(delta):
	if base == null: return
	
	if bed == null:
		#search for a bed this teenager owns
		var found = false
		for object in get_tree().get_nodes_in_group("Object"):
			if object.type == object.TYPE.BED:
				if object.owner_id == base.teenager.id:
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
		
	else:
		pass
	
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	bed = null
	emit_signal("finished")