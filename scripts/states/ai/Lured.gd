extends Node

"""
	Teenager Lured state
"""

signal finished

var base
var trap
var following_trail = false
var trail setget set_trail
var teenager
var _timer

#constructor
#warning-ignore:unused_argument
#warning-ignore:unused_argument
func init(base,state_position,state_time):
	#TODO: check if the teenager can be affect by this kind of trap
	self.base = base
	teenager = base.teenager
	trap = teenager.get_traps()[0]
	trap.is_used = true #TODO: only do this if there's two teenagers using it
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
	
#warning-ignore:unused_argument
func update(delta):
	if !following_trail or trail.size() == 0:
		return
	
	if teenager.walk(trail[0]):
		#he arrived at this section of the trail, go to the next then
		set_trail(trap.remove_piece(trail[0]))

#destructor
func exit():
	if _timer.is_connected("timeout",self,"start_following_trail"):
		_timer.disconnect("timeout",self,"start_following_trail")
		
	if _timer.is_connected("timeout",self,"exit"):
		_timer.disconnect("timeout",self,"exit")
	
	if base.has_node("lure_timer"):
		base.get_node("lure_timer").queue_free()
	
	if not base.is_routine_over:
		base._on_routine = true
	teenager.remove_trap(trap,true)
	following_trail = false
	emit_signal("finished")
	
	
#when the teenager starts to follow the trail again
func start_following_trail():
	following_trail = true
	_timer.stop()

func set_trail(value):
	trail = value
	
	if trail.size() == 0:
		#end of the trail. wait a few seconds before exiting this state
		_timer.set_wait_time(4)
		_timer.disconnect("timeout",self,"start_following_trail")
		_timer.connect("timeout",self,"exit")
		_timer.start()


