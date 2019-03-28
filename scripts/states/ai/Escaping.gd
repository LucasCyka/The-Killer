extends Node

"""
	Teenager Escaping state
"""

signal finished
signal entered

var base
var regroup_point
var is_group_ready = false
var teenagers

#constructor
func init(base,state_position,state_time):
	regroup_point = state_position
	self.base = base
	self.teenagers = get_tree().get_nodes_in_group("AI")
	self.base.teenager.speed += 10
	
	#print(regroup_point)
	#check if this is the first teenager to start escaping
	#if so, then alert the others
	var teenagers_escaping = []
	for teenager in teenagers:
		if teenager.state_machine.get_current_state() == 'Escaping':
			teenagers_escaping.append(teenager)
	if teenagers_escaping.size() > 1:
		return
	
	for teenager in teenagers:
		#TODO: check if there's not any teenager at panic mode or dead
		if teenager.state_machine.get_current_state() != 'Escaping':
			#all the teenagers will regroup and start to run off
			#change all the teenagers state
			regroup_point = base.teenager.kinematic_teenager.global_position
			teenager.state_machine.is_routine_over = true
			teenager.state_machine.state_position = regroup_point
			teenager.state_machine.force_state('Escaping')
	
	emit_signal("entered")
	
func update(delta):
	if regroup_point == null:
		return
	
	if not is_group_ready:
		#check if every npc is near the regroup point
		if base.teenager.kinematic_teenager.global_position.distance_to(regroup_point) < 40:
			#check if all npc's are also in the regroup point before start
			#running
			for teenager in teenagers:
				is_group_ready = true
				if teenager.kinematic_teenager.global_position.distance_to(regroup_point) > 40:
					is_group_ready = false
					break
		else:
			#move to the regroup point
			base.teenager.walk(regroup_point)
		
	
	if not is_group_ready:
		return
	#start running
	#TODO: use a pre-set escape point
	for teenager in teenagers:
		#ensure the group is really ready
		if teenager.state_machine.get_current_state() == 'Escaping':
			if teenager.state_machine.get_node('Escaping').is_group_ready == false:
				return
		else:
			return
	base.teenager.walk(Vector2(-5000,-5000))
	
func exit():
	emit_signal("finished")
	
	
