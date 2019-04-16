extends Node

"""
	Teenager Escaping state
"""

signal finished
signal entered

var base
var escape_point
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
	self.kinematic_teenager = base.teenager.kinematic_teenager
	self.base.teenager.is_escaping = true
	self.teenagers = get_tree().get_nodes_in_group("AI")
	self.base.teenager.speed += 10
	self.game = self.base.teenager.get_parent().get_parent()
	self.escape_point = game.get_escaping_point()
	emit_signal("entered")
	
func update(delta):
	if game == null:
		return
	teen_pos = kinematic_teenager.global_position
	
	if base.teenager.saw_player: is_avoiding_player = true
	
	#is seeing the player, check if he can reach the exit point
	if is_avoiding_player:
		var player = game.get_player()
		
		if player == null and !is_desperado:
			#the player exited and he's not running from him
			base.teenager.saw_player = false
			is_avoiding_player = false
		elif is_path_free(escape_point) and !is_desperado:
			#he can walk towards the exit and isn't running from the player
			base.teenager.saw_player = false
			is_avoiding_player = false
		else:
			#he needs to run from the player and enters on 'desperado' mode
			#TODO: check if him can escape by boat/car or something else
			is_desperado = true
			
			if player != null:
				if player.kinematic_player.global_position.distance_to(teen_pos) > 700:
					base.teenager.saw_player = false
					is_avoiding_player = false
					is_desperado = false
					return
					
				if player.kinematic_player.global_position.distance_to(teen_pos) < 30 and player != null:
					#he's too close to the player, cornered.
					base.force_state('Cornered')
					return
			
			if avoidant_tile == null:
				#search for a tile to run
				avoidant_tile = get_avoidant_tile()
				if avoidant_tile == null:
					#he's cornered, and can't escape anymore
					base.force_state('Cornered')
					return
			
			#walk towards the avoidant tile (opposite to the player)
			if base.teenager.walk(avoidant_tile):
				#TODO: maybe walk more than one avoidant tile?
				avoidant_tile = null
				is_desperado = false
			
			return
			
		
	#walk towards the exit point
	avoidant_tile = null
	if base.teenager.walk(escape_point) or teen_pos.distance_to(escape_point) < 80:
		base.force_state('Escaped')
	
	#TODO: call other teens into escaping aswell.

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

#destructor
func exit():
	self.base.teenager.speed -= 10
	game = null
	avoidant_tile = null
	is_desperado  = false
	is_avoiding_player = false
	emit_signal("finished")
	
	
