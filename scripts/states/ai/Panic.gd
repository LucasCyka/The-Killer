extends Node

"""
	Teenager Panic state
"""

signal finished
signal entered

var base
var teenagers
var closest_teenager
var _timer
var is_running = false setget set_is_running
var is_avoiding_player = false
var kinematic_teenager
var teen_pos
var game
var avoidant_tile

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.traps.clear()
	self.base.is_routine_over = true
	self.base.teenager.speed += 10
	self.teenagers = get_tree().get_nodes_in_group("AI")
	self.base.teenager.set_fear(100,false)
	self.kinematic_teenager = base.teenager.get_child(0)
	self.game = self.base.teenager.get_parent().get_parent()
	
	#the teenager only start running after this timer
	_timer = Timer.new()
	_timer.set_wait_time(3)
	_timer.name = "PanicTimer"
	_timer.connect("timeout",self,"set_is_running",[true])
	_timer.set_one_shot(true)
	base.add_child(_timer)
	_timer.start()
	
	emit_signal("entered")
	
func update(delta):
	if not is_running:
		return
		
	teen_pos = kinematic_teenager.global_position
	
	#TODO: irregular movements, nerf the running effect etc
	#TODO: check if the closest teenager still alive
	#TODO: check if theres any teenager alive
	#TODO: make some teenagers more likely to start fighting than running
	#or screaming
	
	#check if he's seeing the player and try to avoid/escape from him
	if base.teenager.saw_player: is_avoiding_player = true
	
	if is_avoiding_player:
		var player = game.get_player()
		#run from the player until reaching a certain distance
		if player == null or game.get_current_mode() != game.MODE.HUNTING:
			#the player is not in the game
			is_avoiding_player = false
		elif player.kinematic_player.global_position.distance_to(teen_pos) > 700:
			#the teen is too far from the player
			base.teenager.saw_player = false
			is_avoiding_player = false
		#elif player.is_indoor != base.teenager.is_indoor:
		#	base.teenager.saw_player = false
		#	is_avoiding_player = false
		else:
			if is_path_free(closest_teenager.kinematic_teenager.global_position):
				pass
				#print("walk to the teenager")
			else:
				#TODO: check if he can enter inside a building

				#check if he's too close to the player
				if player.kinematic_player.global_position.distance_to(teen_pos) < 30:
					base.force_state('Cornered')
					return
				#try to escape, avoiding the player
				if avoidant_tile == null:
					avoidant_tile = get_avoidant_tile()
					if avoidant_tile == null:
						#he's cornered by the player
						base.force_state('Cornered')
						return
						#print("fight or die")
				else:
					if base.teenager.walk(avoidant_tile):
						avoidant_tile = null
						return
					#print("he's avoiding...")
					if not is_path_free(avoidant_tile):
						avoidant_tile = null
						return
				return
			
			"""
			#run in the opposite direction
			var player_pos = player.kinematic_player.global_position
			
			var direction = teen_pos - player_pos
			direction = direction.normalized()
			
			
			var final_pos = star.get_closest_tile((teen_pos + direction*50))
			
			base.teenager.walk(final_pos)
			
			return
			"""
	
	var distance = closest_teenager.get_child(0).global_position.distance_to(kinematic_teenager.global_position) 
	var is_visible = base.teenager.is_object_visible(closest_teenager.detection_area)
	avoidant_tile = null
	
	if base.teenager.walk(closest_teenager.get_child(0).global_position) or (distance < 60 and is_visible):
		is_running = false
		#start the escape
		if closest_teenager.state_machine.get_current_state() != 'Panic':
			closest_teenager.state_machine.force_state('Escaping')
		else:
			closest_teenager = get_closest_teenager()
			if closest_teenager == null:
				base.teenager.saw_player = true
				base.force_state('Escaping')
			return
		base.teenager.saw_player = false
		base.force_state('Escaping')
		#exit()
		
#when the teenager start to run like an idiot
func set_is_running(value):
	is_running = value
	
	closest_teenager = get_closest_teenager()
	if closest_teenager == null:
		base.teenager.saw_player = true
		base.force_state('Escaping')
	"""
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
	"""

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

#return the closest teenager
func get_closest_teenager():
	#order the teenagers by distance to this teenager
	var positions = []
	var closest = base.teenager
	
	for teenager in teenagers:
		var state = teenager.state_machine.get_current_state()
		#TODO: check if he's not dead
		if teenager != base.teenager and state != 'Panic' and state != 'Dead':
			positions.append(teenager.get_child(0).global_position)
	
	positions = common.order_by_distance(positions,base.teenager.get_child(0).global_position)
	
	if positions == []:
		return null
	
	#seach the closest teenager
	for teenager in teenagers:
		if teenager.get_child(0).global_position == positions.front():
			closest = teenager
			break
	
	return closest
	
#destructor
func exit():
	if _timer != null:
		if _timer.is_connected("timeout",self,"set_is_running"):
			_timer.disconnect("timeout",self,"set_is_running")
		_timer.queue_free()
		_timer = null
		self.base.teenager.speed -= 10 
		is_avoiding_player = false
		game = null
	emit_signal("finished")