extends Node

"""
	Teenager dead state
"""

signal finished
signal entered

var base
var game
var teenagers = []
var affected_teenagers = []

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	self.game = base.teenager.get_parent().get_parent()
	self.teenagers = get_tree().get_nodes_in_group("AI")
	
	#TODO: points should be weighted different according to some teenagers
	#modifiers.
	score.set_score(game.get_level(),score.get_score(game.get_level()) + 100)
	
	
	emit_signal("entered")
	
func update(delta):
	if teenagers == []:
		return
	var teen_pos = base.teenager.kinematic_teenager.global_position
	
	#teenages near dead bodies will enter on panic/shock
	for teen in teenagers:
		if teen == base.teenager:
			continue
		var pos = teen.kinematic_teenager.global_position
		
		#check if the teen is close enough
		if pos.distance_to(teen_pos) <100:
			#check if he can see the dead teen
			var dir = pos.normalized() - teen_pos.normalized()
			var facing = dir.dot(teen.facing_direction)
			var is_visible = teen.is_object_visible(base.teenager.detection_area)
			
			if floor(facing) == -1 and is_visible and affected_teenagers.find(teen) == -1:
				affected_teenagers.append(teen)
				teen.state_machine.force_state('Panic')
				print("panic by dead")
			elif is_visible and pos.distance_to(teen_pos) <60 and affected_teenagers.find(teen) == -1:
				affected_teenagers.append(teen)
				teen.state_machine.force_state('Panic')
				print("panic by dead")
	
	#TODO: sync dead animation with player attacking animation
	pass
	
#destructor
func exit():
	emit_signal("finished")