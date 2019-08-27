extends Node

"""
	Teenager CheckingLight state
"""

signal finished
signal entered

const fix_duration = 20

var base
var generator
var generator_obj = null
var teenager
var game
var timer
var teenagers
var finished = false

func init(base,state_position,state_time):
	self.base = base
	self.base.is_forced_state = false
	self.teenager = self.base.teenager
	self.teenager.state_animation = false
	self.game = teenager.get_parent().get_parent()
	self.teenagers = get_tree().get_nodes_in_group('AI')
	self.finished = false
	
	#search the generator
	for object in game.get_world_objects():
		if object.type == object.TYPE.POWER:
			self.generator = star.get_closest_tile(object.global_position)
			self.generator_obj = object
			break
	if generator == null:
		print('Generator not found!')
		print('Check if you have a world object with the POWER type.')
		exit()
	
	#time to fix the generator
	timer = preload('res://scenes/CustomTimer.tscn').instance()
	add_child(timer)
	timer.stop()
	timer.one_shot = true
	timer.connect('timeout',self,'fix_lights')
	timer.set_wait_time(fix_duration)
	
	emit_signal("entered")
	
func update(delta):
	if base == null or finished:
		print(finished)
		return
	
	#check if there are not other teens checking the light
	var teens = []
	for teen in teenagers:
		var s = teen.state_machine.get_current_state()
		if teen != teenager and s == 'CheckingLight':
			teens.append(teen.id) 
	 
	if teens != []:
		#there are more than one teen checking the light, choice the 
		#with the one closes to the generator
		teens.append(teenager.id)
		if teens.max() != teenager.id: 
			finished = true
			exit()
			
	elif teenager.global_position.distance_to(generator) > 20:
		#walk towards the generator
		teenager.walk(generator)
	else:
		if timer != null:
			if timer.is_stopped():
				timer.start()
				var _custom = Node.new()
				_custom.name = 'Waiting'
				teenager.custom_animation = _custom

func fix_lights():
	generator_obj.use(base.teenager)
	game.has_light = true
	game.update_lights(true)
	finished = true
	exit()

func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	
	if timer != null:
		timer.disconnect('timeout',self,'fix_lights')
		timer.call_deferred('free')
		timer = null
		teenager.custom_animation = null
	if generator_obj != null: generator_obj.leave(base.teenager)
	generator = null
	generator_obj = null
	emit_signal("finished")

