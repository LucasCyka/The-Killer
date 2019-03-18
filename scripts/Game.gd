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

#user interface
onready var ui = $GameUI

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

#return the tilemap of containing floor tiles. It's used by traps.
func get_floor_tile():
	#TODO: return also A* tiles
	return $Tiles/Floor

#return walls of buildings in the map
func get_wall_tile():
	#TODO: this will also return some floor tiles, change this later...
	return $Tiles/Buildings

#change the current game mode
func set_current_mode(value):
	current_mode = value
	
	if current_mode == MODE.HUNTING:
		#init the hunting mode
		disable_spawn_points()
		ui.lock()
	elif current_mode == MODE.PLANNING:
		ui.unlock()
		pass
	else:
		#the game is paused...
		pass

func get_current_mode():
	return current_mode

#get traps that are placed on the map
func get_placed_traps():
	var traps = get_tree().get_nodes_in_group("Misc")
	traps = traps + get_tree().get_nodes_in_group("Vice")
	traps = traps + get_tree().get_nodes_in_group("Lure")
	
	return traps

#show all the spawn points and return an array containing their position
func enable_spawn_points():
	var spawn = $Tiles/SpawnPoints
	
	spawn.show()
	
	var positions = []
	
	for tile in spawn.get_used_cells():
		positions.append(spawn.map_to_world(tile))
		
	return positions

func disable_spawn_points():
	$Tiles/SpawnPoints.hide()

#get current level path
func get_level():
	return self.filename




