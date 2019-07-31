extends Node

"""
	Teenager Crippled state
"""

signal finished
signal entered

var base
var game

func init(base,state_position,state_time):
	self.base = base
	self.game = base.teenager.get_parent().get_parent()
	self.game.audio_system.play_2d_sound('Falling',base.teenager.global_position)
	self.base.teenager.state_animation = true
	self.base.teenager.teenager_anims.connect('animation_finished',self,
	'start_animation')
	
	emit_signal("entered")
	
func update(delta):
	pass

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