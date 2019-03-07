extends Node2D

"""
	Control lots of the aspects about the gameplay.
	Things like game over events, points distribution, world information etc...
"""

enum MODE {
	PLANNING,
	HUNTING,
	PAUSED
}

var current_mode = MODE.PLANNING setget set_current_mode, get_current_mode

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
#if the closest tile is higher than limit, then it will return pos.
func get_closest_tile(tilemap,pos,limit=100):
	var map_tiles = tilemap.get_used_cells()
	var world_tiles = []
	var distance = [] 
	var closest = pos
	
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

#change the current game mode
func set_current_mode(value):
	current_mode = value
	
	if current_mode == MODE.HUNTING:
		#init the hunting mode
		#TODO: lock the UI
		pass
	else:
		#TODO: check if there's any hunter in game
		pass

func get_current_mode():
	return current_mode













