extends Node2D

"""
	Control lots of the aspects about the gameplay.
	Things like game over events, points distribution, world information etc...
"""

#TODO: INITIALIZE
func _ready():
	pass

#return all the teenagers in the game
func get_teenagers():
	return get_tree().get_nodes_in_group("AI")

#return the current player controller
func get_player_controller():
	return get_node("PlayerController")
	
#get the closest tile from 'pos' in a given 'tileset'.
#if the closest tile is higher than limit, then it will return null.
func get_closest_tile(tilemap,pos,limit=100):
	var map_tiles = tilemap.get_used_cells()
	var world_tiles = []
	var distance = [] 
	var closest = null
	
	#convert all tiles map positions their positions in the real world
	for tile in map_tiles:
		world_tiles.append(tilemap.map_to_world(tile))
		
	#get the distance from 'pos' for each tile
	for tile in world_tiles:
		distance.append(tile.distance_to(pos))
	distance.sort()
	
	#if the distance is less than the limit, return the closest tile
	if distance.front() < limit:
		for tile in world_tiles:
			if tile.distance_to(pos) == distance.front():
				closest = tile
				break
	
	return closest

#return the tilemap that things can be put
func get_floor_tile():
	return $Tiles/Floor

#TODO: return also A* tiles






