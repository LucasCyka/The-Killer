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
	
	
	#check if he's seeing the player and try to avoid/escape from him
	if base.teenager.saw_player: is_avoiding_player = true
	
	if is_avoiding_player:
		var player = game.get_player()
		#run from the player until reaching a certain distance
		if player == null or game.get_current_mode() != game.MODE.HUNTING:
			#the player is not in the game
			is_avoiding_player = false
		elif player.kinematic_player.global_position.distance_to(teen_pos) > 200:
			#the teen is too far from the player
			is_avoiding_player = false
		else:
			if is_path_free(closest_teenager.kinematic_teenager.global_position):
				print("walk to the teenager")
			else:
				#TODO: check if he can enter inside a building
				#TODO: check if he's too close to the player
				#try to escape, avoiding the player
				if avoidant_tile == null:
					avoidant_tile = get_avoidant_tile()
				else:
					base.teenager.walk(avoidant_tile)
					
					if not is_path_free(avoidant_tile):
						print("time for a new path")
						pass
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
func get_avoidant_tile(random=true,position=Vector2(0,0)):
	#TODO: not random path
	
	var final_tile = null
	
	#random path
	var tilemap = game.get_pathfinding_tile()
	var tiles_position = common.convert_to_world(tilemap.get_used_cells(),tilemap)
	tiles_position = common.order_by_distance(tiles_position,kinematic_teenager.global_position)
	
	#check if there's a tile that can avoid the player.
	#the tile must have a path to the player bigger than 20
	#and should also be free from the player interference
	for tile in tiles_position:
		#the path to this tile
		#var path = star.find_path(kinematic_teenager.global_position,tile)
		
		if tile.distance_to(kinematic_teenager.global_position) > 300:
			if is_path_free(tile):
				final_tile = tile
				break
	
	return final_tile

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