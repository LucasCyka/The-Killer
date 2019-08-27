extends Node

"""
	Teenager shitting state
"""

signal finished
signal entered

var base
var bathroom
var started = false setget set_started #when the teen starts to search for a bathroom
var timer
var game

const start_duration = 2

func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	self.base.is_forced_state = false
	self.game = self.base.teenager.get_parent().get_parent()
	#custom animation
	self.base.teenager.custom_animation = base.get_node('Shock')
	self.base.teenager.speed += 10
	self.base.teenager.teenager_anims.set_speed_scale(2)
	
	timer = preload('res://scenes/CustomTimer.tscn').instance()
	add_child(timer)
	timer.stop()
	timer.one_shot = true
	timer.connect('timeout',self,'set_started',[true])
	timer.set_wait_time(start_duration)
	timer.start()
	
	#TODO: bowels balloons
	self.base.teenager.is_talking = false
	self.base.teenager.is_thinking = true
	self.base.teenager.custom_balloons = ['shit','bad','loo']
	
	emit_signal("entered")
	
func update(delta):
	if base == null or not started:
		return
	self.base.teenager.teenager_anims.set_speed_scale(2)
	
	if bathroom == null:
		bathroom = base.teenager.get_parent().get_parent().get_free_bathroom()
	elif bathroom.global_position.distance_to(base.teenager.global_position) > 20:
		base.teenager.walk(bathroom.global_position)
		self.base.teenager.custom_animation = null
	elif bathroom.current_teen != []:
		#the bathroom is occupied, wait in there
		self.base.teenager.custom_animation = base.get_node('Shock')
	else:
		#hide it and wait for the diarrhea to end
		self.base.teenager.global_position = bathroom.global_position
		self.base.teenager.teenager_anims.hide()
		self.base.teenager.custom_animation = base.get_node('Idle')
		
		if not self.base.teenager.diarrhea: 
			started = false
			exit()
	
	
#when the teen starts to search for a bathroom
func set_started(value):
	started = value
	
	if started:
		timer.call_deferred('free')
		timer = null
	
func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	
	if base.teenager.diarrhea:
		base.teenager.was_in_bathroom = false
	started = false
	bathroom = null
	base.teenager.teenager_anims.show()
	base.teenager.custom_animation = null
	self.base.teenager.is_thinking = false
	self.base.teenager.custom_balloons = []
	self.base.teenager.speed -= 10
	
	if game.timer_speed == game.default_speed:
		self.base.teenager.teenager_anims.set_speed_scale(1)
	elif game.timer_speed == game.fast_speed:
		self.base.teenager.teenager_anims.set_speed_scale(2)
	elif game.timer_speed == game.ultra_speed:
		self.base.teenager.teenager_anims.set_speed_scale(3)
	
	emit_signal("finished")