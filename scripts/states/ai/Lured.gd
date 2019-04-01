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

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.is_forced_state = false
	teenager = base.teenager
	trap = teenager.get_traps()[teenager.current_trap]
	if trap.is_one_shot():
		trap.is_used = true
	else: trap.is_used = false
	
	trail = trap.get_trail()
	
	#the teenager will only follow the trail after a few seconds when 
	#he see the lure. The time is controlled by the timer below.
	_timer = Timer.new()
	_timer.name = "lure_timer"
	_timer.set_wait_time(4)
	_timer.connect("timeout",self,"start_following_trail")
	base.add_child(_timer)
	_timer.start()
	
	#TODO: there's a problem here: the teenager will try to follow the path
	#in all directions. This is unrealistic and to solve this I need to remove
	#some pieces from this trail
	trail = common.order_by_distance(trail,teenager.kinematic_teenager.global_position)
	
	emit_signal("entered")
	
func update(delta):
	if !following_trail or trail.size() == 0:
		return
	if not trap.is_one_shot() and trail.size()-1 == current_section:
		return
	
	if teenager.walk(trail[current_section]):
		if trap.is_one_shot():
			#he arrived at this section of the trail, go to the next then
			set_trail(trap.remove_piece(trail[current_section]))
		else:
			current_section +=1 
			set_trail(trail)
			
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
	
	following_trail = false
	current_section = 0
	emit_signal("finished")
	
	
#when the teenager starts to follow the trail again
func start_following_trail():
	following_trail = true
	_timer.stop()

func set_trail(value):
	trail = value
	
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


