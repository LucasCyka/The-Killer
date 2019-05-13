extends Node

"""
	Teenager Lured state
"""

signal finished
signal entered

var base
var trap
var following_trail = false
var trail setget set_trail
var teenager
var _timer
var current_section = 0 #the piece of trail the teen is currently following
var initial_position

#constructor
func init(base,state_position,state_time):
	self.base = base
	base.teenager.state_animation = false
	base.teenager.custom_animation = base.get_node('Idle')
	self.base.is_forced_state = false
	teenager = base.teenager
	initial_position = teenager.kinematic_teenager.global_position
	trap = teenager.get_traps()[teenager.current_trap]
	if trap.is_one_shot():
		trap.is_used = true
	else: trap.is_used = false
	
	#traps that aren't oneshot need to store the current section of a trail
	if not trap.is_one_shot():
		if trap.trail_position.has(teenager.id):
			current_section = trap.trail_section[teenager.id]
			initial_position = trap.trail_position[teenager.id]
		else:
			trap.trail_section[teenager.id] = current_section
			trap.trail_position[teenager.id] = initial_position
	
	trail = trap.get_trail()
	
	#the teenager will only follow the trail after a few seconds when 
	#he see the lure. The time is controlled by the timer below.
	_timer = preload("res://scenes/AITimer.tscn").instance()
	_timer.name = "lure_timer"
	base.add_child(_timer)
	_timer.set_wait_time(4)
	_timer.connect("timeout",self,"start_following_trail")
	_timer.start()
	
	#will define the order the teenager will follow the trail
	trail = common.order_by_distance(trail,initial_position)
	
	"""
	var id = 0
	for piece in trail:
		var label = Label.new()
		label.text =str(int(piece.distance_to(teenager.kinematic_teenager.global_position)))
		label.text = label.text + ": " + str(id)
		label.rect_global_position = piece
		base.add_child(label)
		id +=1
	"""
	emit_signal("entered")
	
func update(delta):
	if !following_trail or trail.size() == 0:
		base.teenager.state_animation = false
		base.teenager.custom_animation = base.get_node('Idle')
		return
	if not trap.is_one_shot() and trail.size()-1 == current_section:
		base.teenager.state_animation = false
		base.teenager.custom_animation = base.get_node('Idle')
		return
	
	if teenager.walk(trail[current_section]):
		if trap.is_one_shot():
			#he arrived at this section of the trail, go to the next then
			set_trail(trap.remove_piece(trail[current_section]))
		else:
			current_section +=1 
			set_trail(trail)
			
			trap.trail_section[teenager.id] = current_section
			
#destructor
func exit():
	if _timer.is_connected("timeout",self,"start_following_trail"):
		_timer.disconnect("timeout",self,"start_following_trail")
		
	if _timer.is_connected("timeout",self,"exit"):
		_timer.disconnect("timeout",self,"exit")
	
	if base.has_node("lure_timer"):
		base.get_node("lure_timer").queue_free()
	
	if not base.is_routine_over and not self.base.is_forced_state:
		base._on_routine = true
		if trap.is_one_shot():
			teenager.remove_trap(trap,true)
		else:
			teenager.remove_trap(trap,false)
	elif self.base.is_forced_state:
		base._on_routine = false
	
	base.teenager.custom_animation = null
	following_trail = false
	current_section = 0
	initial_position = null
	emit_signal("finished")
	
	
#when the teenager starts to follow the trail again
func start_following_trail():
	following_trail = true
	base.teenager.state_animation = false
	base.teenager.custom_animation = null
	_timer.stop()

func set_trail(value):
	trail = value
	
	if trail.size() != 0:
		trail = common.order_by_distance(trail,initial_position)
	
	if trap.is_one_shot():
		if trail.size() == 0:
			#end of the trail. wait a few seconds before exiting this state
			_timer.set_wait_time(4)
			_timer.disconnect("timeout",self,"start_following_trail")
			_timer.connect("timeout",self,"exit")
			_timer.start()
	else:
		if trail.size()-1 == current_section:
			#end of the trail. wait a few seconds before exiting this state
			_timer.set_wait_time(4)
			_timer.disconnect("timeout",self,"start_following_trail")
			_timer.connect("timeout",self,"exit")
			_timer.start()


