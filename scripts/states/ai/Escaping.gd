extends Node

"""
	Teenager Escaping state
"""

signal finished
signal entered

var base
var escape_point
var escape_object
var tried_escape_object = false
var is_avoiding_player = false
var is_desperado = false
var avoidant_tile = null
var teen_pos
var teenagers
var kinematic_teenager
var game

#constructor
func init(base,state_position,state_time):
	#regroup_point = state_position
	self.base = base
	self.base.teenager.state_animation = false
	self.base.teenager.teenager_anims.set_speed_scale(2)
	self.kinematic_teenager = base.teenager.kinematic_teenager
	self.base.teenager.is_escaping = true
	self.teenagers = get_tree().get_nodes_in_group("AI")
	self.base.teenager.speed += 10
	self.base.teenager.set_fear(100,false)
	self.game = self.base.teenager.get_parent().get_parent()
	self.escape_point = game.get_escaping_point(base.teenager.get_position())
	self.escape_object = game.get_escape_object(base.teenager.get_position())
	
	#custom anim
	var custom = Node.new()
	custom.name = "Panic"
	base.teenager.custom_animation = custom
	
	emit_signal("entered")
	
func update(delta):
	if game == null:
		return
	
	#call other teens into escaping aswell.
	base.teenager.call_into_escaping()
	
	teen_pos = kinematic_teenager.global_position
	#since the animations speed can be chaned by the clock feature
	self.base.teenager.teenager_anims.set_speed_scale(2)
	
	if base.teenager.saw_player: is_avoiding_player = true
	
	#is seeing the player, check if he can reach the exit point
	if is_avoiding_player and not base.teenager.is_immune:
		var player = game.get_player()
		
		if player == null and !is_desperado:
			#the player exited and he's not running from him
			base.teenager.saw_player = false
			is_avoiding_player = false
		elif is_desperado:
			if base.teenager.walk(avoidant_tile):
				self.escape_point = game.get_escaping_point(base.teenager.get_position())
				if is_path_free(escape_point) or (is_path_free(escape_object.global_position) and !tried_escape_object):
					avoidant_tile = null
					base.teenager.saw_player = false
					is_avoiding_player = false
				else: 
					is_desperado = false
			return
		else:
			if not is_path_free(escape_point):
				
				if is_path_free(escape_object.global_position) and not tried_escape_object:
					#just for debug
					print("The AI should go check the car")
				else:
					is_desperado = true
					avoidant_tile = get_avoidant_tile()
					if avoidant_tile == null:
						base.force_state('Cornered')
					
					
					return
			
			#TODO: check if he can't escape the level avoiding the player.
			#if not then he needs to enter on the 'desperado state'. He
			#can only exit this 'state' when he is: 1- far enough from
			#the player or reached an 'avoidant tile'.
	
	if base.teenager.is_immune:
		#the teen is trying to escape, just wait
		return
	
	if is_path_free(escape_object.global_position) and not tried_escape_object:
		if base.teenager.walk(escape_object.global_position) or teen_pos.distance_to(escape_point) < 80:
			game.audio_system.play_2d_sound('CarDoor',base.teenager.global_position)
			print('arrived at the object')
			escape_object.use(base.teenager)
			base.teenager.hide()
			base.teenager.is_immune = true #the player can't attack him here
			tried_escape_object = true
			if escape_object.is_broken:
				leave_object()
			else: escape_on_object()
	else:
		#walk towards the exit point
		if base.teenager.walk(escape_point) or teen_pos.distance_to(escape_point) < 80:
			base.force_state('Escaped')
	

#check if the teenager can arrive in a given position and avoid the player
func is_path_free(pos):
	#the path the teen must walk
	var path = star.find_path(kinematic_teenager.global_position,pos)
	
	#check if any spot of the path is too close to the player
	if path.size() > 1 and game.current_mode == game.MODE.HUNTING:
		var player = game.get_player()
		
		for spot in path:
			if spot.distance_to(player.kinematic_player.global_position) < 50:
				return false
	
	return true

#return a tile in the map that can be reach while avoiding the player
func get_avoidant_tile():
	var final_tile = null
	#pathfinding tilemap
	var tilemap = game.get_pathfinding_tile()
	var teenager_map_position = tilemap.world_to_map(teen_pos)
	var cells = tilemap.get_used_cells()
	
	#possible alternatives, 12 tiles away from the teen
	var tiles = [
		Vector2(teenager_map_position.x+15,teenager_map_position.y),
		Vector2(teenager_map_position.x-15,teenager_map_position.y),
		Vector2(teenager_map_position.x,teenager_map_position.y+15),
		Vector2(teenager_map_position.x,teenager_map_position.y-15),
		Vector2(teenager_map_position.x-15,teenager_map_position.y-15),
		Vector2(teenager_map_position.x+15,teenager_map_position.y+15),
		Vector2(teenager_map_position.x+15,teenager_map_position.y-15),
		Vector2(teenager_map_position.x-15,teenager_map_position.y+15)
	]
	tiles.shuffle()
	#check if the teenager can escape throught the alternatives above
	for tile in tiles:
		if cells.find(tile) != -1:
			if is_path_free(tilemap.map_to_world(tile)):
				final_tile = tilemap.map_to_world(tile)
				break
	
	return final_tile

#escape from the game using the escape object
func escape_on_object(timer=false):
	if timer:
		base.force_state('Escaped')
	else:
		var escape_timer = Timer.new()
		escape_timer.wait_time = 2
		escape_timer.connect('timeout',self,'escape_on_object',[true])
		escape_timer.one_shot = true
		add_child(escape_timer)
		escape_timer.start()

#can't use this escape object, try to reach the escaping point
func leave_object(timer=false):
	if timer:
		base.teenager.is_immune = false
		base.teenager.show()
	else:
		var escape_timer = Timer.new()
		escape_timer.wait_time = 3
		escape_timer.connect('timeout',self,'leave_object',[true])
		escape_timer.one_shot = true
		add_child(escape_timer)
		escape_timer.start()


#destructor
func exit():
	self.base.teenager.speed -= 10
	game = null
	avoidant_tile = null
	is_desperado  = false
	is_avoiding_player = false
	base.teenager.is_immune = false
	base.teenager.custom_animation = null
	emit_signal("finished")
	
	
