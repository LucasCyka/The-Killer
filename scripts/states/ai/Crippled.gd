extends Node

"""
	Teenager Crippled state
"""

signal finished
signal entered

var base
var game
var teenagers
var teen_pos
var affected_teenagers = []

func init(base,state_position,state_time):
	self.base = base
	self.game = base.teenager.get_parent().get_parent()
	self.teenagers = game.get_teenagers_alive()
	self.game.audio_system.play_2d_sound('Falling',base.teenager.global_position)
	self.base.teenager.state_animation = true
	self.base.teenager.teenager_anims.connect('animation_finished',self,
	'start_animation')
	
	emit_signal("entered")
	
func update(delta):
	if base == null:
		return
	teen_pos = base.teenager.global_position
	#scare teens who sees someone else crippled
	for teen in teenagers:
		if not is_instance_valid(teen):
			continue
		
		if teen == base.teenager or not teen is KinematicBody2D:
			continue
		var pos = teen.kinematic_teenager.global_position
		
		#check if the teen is close enough
		if pos.distance_to(teen_pos) <100:
			#check if he can see the crippled teen
			var dir = pos.normalized() - teen_pos.normalized()
			var facing = dir.dot(teen.facing_direction)
			var is_visible = teen.is_object_visible(base.teenager.detection_area)
			
			#check if the teen isn't on shock
			if teen.state_machine.get_current_state() == 'Shock' and affected_teenagers.find(teen) == -1:
				affected_teenagers.append(teen)
				#give some score points to the player since he's making
				#someone scary even more scarier.
				teen.set_fear(50,false)
				return
			
			if floor(facing) == -1 and is_visible and affected_teenagers.find(teen) == -1:
				affected_teenagers.append(teen)
				teen.state_machine.force_state('Panic')
				print("panic by crippled")
			elif is_visible and pos.distance_to(teen_pos) <60 and affected_teenagers.find(teen) == -1:
				affected_teenagers.append(teen)
				teen.state_machine.force_state('Panic')
				print("panic by crippled")

func start_animation():
	self.base.teenager.teenager_anims.disconnect('animation_finished',self,
	'start_animation')
	self.base.teenager.state_animation = false
	var custom_anim = Node.new()
	custom_anim.name = 'Crippled2'
	base.teenager.custom_animation = custom_anim

func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	base.teenager.custom_animation = null
	emit_signal("finished")