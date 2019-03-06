extends Node

"""
	Teenager Panic state
"""

signal finished

var base
var teenagers
var closest_teenager
var _timer
var is_running = false setget set_is_running
var kinematic_teenager

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.speed *= 2 
	self.teenagers = get_tree().get_nodes_in_group("AI")
	self.base.teenager.set_fear(100)
	self.kinematic_teenager = base.teenager.get_child(0)
	
	#the teenager only start running after this timer
	_timer = Timer.new()
	_timer.set_wait_time(3)
	_timer.name = "PanicTimer"
	_timer.connect("timeout",self,"set_is_running",[true])
	_timer.set_one_shot(true)
	base.add_child(_timer)
	_timer.start()
	
func update(delta):
	if not is_running:
		return
	
	#TODO: irregular movements, nerf the running effect etc
	#TODO: check if the closest teenager still alive
	#TODO: check if theres any teenager alive
	
	var distance = closest_teenager.get_child(0).global_position.distance_to(kinematic_teenager.global_position) 
	if base.teenager.walk(closest_teenager.get_child(0).global_position) or distance < 60:
		is_running = false
		#start the escape
		closest_teenager.state_machine.force_state('Escaping')
		exit()
		
#when the teenager start to run like an idiot
func set_is_running(value):
	is_running = value
	
	if is_running == true:
		#order the teenagers by distance to this teenager
		var positions = []
		for teenager in teenagers:
			if teenager != base.teenager:
				positions.append(teenager.get_child(0).global_position)
		
		positions = common.order_by_distance(positions,base.teenager.get_child(0).global_position)
		
		#seach the closest teenager
		for teenager in teenagers:
			if teenager.get_child(0).global_position == positions.front():
				closest_teenager = teenager
				break

#destructor
func exit():
	if _timer != null:
		if _timer.is_connected("timeout",self,"set_is_running"):
			_timer.disconnect("timeout",self,"set_is_running")
		_timer.queue_free()
		_timer = null
		self.base.teenager.speed /= 2 
	emit_signal("finished")