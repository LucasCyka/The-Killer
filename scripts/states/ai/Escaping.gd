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
var buildings_tiles
var building_tile
var last_path_free = null
var last_path_pos = null
var last_current_pos = null

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
			#print('checking... 1')
			if not is_path_free(escape_point):
				
				if is_path_free(escape_object.global_position) and not tried_escape_object:
					#just for debug
					pass
					#print("The AI should go check the car")
				elif is_building_free(teen_pos):
					#try to escape to a building
					base.teenager.is_escaping = false
					base.teenager.is_barricading = true
					game = null
					base.force_state('Barricading')
					#print('go barricading')
					return
				else:
					is_desperado = true
					avoidant_tile = get_avoidant_tile()
					if avoidant_tile == null:
						game = null
						base.force_state('Cornered')
					
					
					return
			
			#TODO: check if he can't escape the level avoiding the player.
			#if not then he needs to enter on the 'desperado state'. He
			#can only exit this 'state' when he is: 1- far enough from
			#the player or reached an 'avoidant tile'.
	
	if base.teenager.is_immune:
		#the teen is trying to escape, just wait
		return
	
	if is_path_free2(escape_object.global_position) and not tried_escape_object:
	#	print('checking... 2')
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

#like is_path_free but more performance wise
func is_path_free2(pos):
	if last_path_free == null:
		return is_path_free(pos)
	
	#check if any spot of the path is too close to the player
	if last_path_free.size() > 1 and game.current_mode == game.MODE.HUNTING:
		var player = game.get_player()
		
		for spot in last_path_free:
			if spot.distance_to(player.kinematic_player.global_position) < 50:
				return false
	
	return true
	#just reuse older paths. 

#check if the teenager can arrive in a given position and avoid the player
func is_path_free(pos):
	#path the teen must walk
	var path = null
	var reuse_path = false
	#try to use old paths to save performance/memory
	if last_path_free != null:
		if pos == last_path_pos:
			#he wants to go to the position he wanted before.
			#if he's not so far from pos than he can reuse the path
			if kinematic_teenager.global_position.distance_to(last_current_pos) < 100:
				reuse_path = true
				path = last_path_free
				last_current_pos = kinematic_teenager.global_position
			
		
	if not reuse_path:
		#create a new path the teen must walk
		path = star.find_path(kinematic_teenager.global_position,pos)
		last_path_free = path
		last_path_pos = pos
		last_current_pos = kinematic_teenager.global_position
		
	#check if any spot of the path is too close to the player
	if path.size() > 1 and game.current_mode == game.MODE.HUNTING:
		var player = game.get_player()
		
		for spot in path:
			if spot.distance_to(player.kinematic_player.global_position) < 50:
				return false
	#else:
	#	last_path_free = null
	#	last_path_pos = null
	#	last_current_pos = kinematic_teenager.global_position
	
	return true
	

#check if the teenager can enter a building and barricade himself
func is_building_free(pos):
	if buildings_tiles == null: 
		buildings_tiles = game.get_indoor_detection()
		buildings_tiles = common.convert_to_world(buildings_tiles.get_used_cells(),buildings_tiles)
		buildings_tiles = common.order_by_distance(buildings_tiles,kinematic_teenager.global_position)
	
	var last_tile = null
	for tile in buildings_tiles:
		if last_tile != null:
			if last_tile.distance_to(tile) < 150:
				continue
		
		last_tile = tile
		if is_path_free(tile):
			if tile.distance_to(kinematic_teenager.global_position) < 25:
				#it's the same tile he already is
				continue
			building_tile = tile
			return true
	
	return false


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
	last_path_free = null
	last_path_pos = null
	last_current_pos = null
	emit_signal("finished")
	
	
