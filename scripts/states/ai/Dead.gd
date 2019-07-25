extends Node

"""
	Teenager dead state
"""

signal finished
signal entered

var base
var game
var teenagers = []
var teenager
var affected_teenagers = []
var player
var dead_anim

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = false
	self.teenager = base.teenager
	self.game = base.teenager.get_parent().get_parent()
	self.teenagers = get_tree().get_nodes_in_group("AI")
	self.player = get_tree().get_nodes_in_group("Player")[0]
	self.teenager.set_fear(100,false)
	
	#TODO: points should be weighted different according to some teenagers
	#modifiers.
	
	score.set_score(game.get_level(),score.get_score(game.get_level()) + 100)
	#var _anim = Node.new()
	#_anim.name = "Dead1"
	#self.base.teenager.custom_animation = _anim
	
	self.base.teenager.teenager_anims.hide()
	self.base.teenager.dead_anims.show()
	
	#sets the dying animation animation
	#TODO: other directions
	#TODO: according the direction according to the player
	var _anim = str(base.teenager.id)+':'+str(player.attacking_animation_id+'-Up')
	base.teenager.dead_anims.set_animation(_anim)
	
	#change the teenager position so when he dies he's facing the player
	#TODO: change the position according to the direction the hunter is facing
	teenager.global_position = Vector2(player.global_position.x,player.global_position.y+20)
	teenager.dead_anims.play(_anim)
	emit_signal("entered")
	
func update(delta):
	if teenagers == []:
		return
	var teen_pos = base.teenager.kinematic_teenager.global_position
	#teenages near dead bodies will enter on panic/shock
	for teen in teenagers:
		if not is_instance_valid(teen):
			continue
		
		if teen == base.teenager or not teen is KinematicBody2D:
			continue
		var pos = teen.kinematic_teenager.global_position
		
		
		#check if the teen is close enough
		if pos.distance_to(teen_pos) <100:
			#check if he can see the dead teen
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
			
			#check if isn't screaming
			if teen.state_machine.get_current_state() == 'Screaming' and affected_teenagers.find(teen) == -1:
				#bonus for seeing someone die
				affected_teenagers.append(teen)
				teen.set_fear(50,false)
			
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