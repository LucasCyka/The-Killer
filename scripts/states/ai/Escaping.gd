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
	self.escape_point = game.get_escaping_point(base.teenager.get_position())
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
		elif player == null and is_desperado:
			if base.walk(avoidant_tile):
				avoidant_tile = null
				base.teenager.saw_player = false
				is_avoiding_player = false
		else:
			pass
			#TODO: check if he can't escape the level avoiding the player.
			#if not then he needs to enter on the 'desperado state'. He
			#can only exit this 'state' when he is: 1- far enough from
			#the player or reached an 'avoidant tile'.
		
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
	
	
