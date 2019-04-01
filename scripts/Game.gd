extends Node2D

"""
	Control several aspects of the gameplay.
	Things like game over events, points distribution, world information etc...
"""

#the game has been loaded
signal loaded

enum MODE {
	PLANNING,
	HUNTING,
	PAUSED
}

var current_mode = MODE.PLANNING setget set_current_mode, get_current_mode
#traps on this level
var traps_data = {}

#user interface
onready var ui = $GameUI
#types of traps
onready var trap_enum = preload("res://scripts/Traps.gd").TYPES

#INITIALIZE
func _ready():
	#A* pathfinding
	star.init($Tiles/Path,Vector2(25,25),false)
	#loads traps information for this level
	load_trap_info()
	
	emit_signal("loaded")
	
#return all the teenagers in the game
func get_teenagers():
	return get_tree().get_nodes_in_group("AI")

#get the player if the game is on the hunting mode
func get_player():
	if get_tree().get_nodes_in_group("Player").size() != 0:
		return $AI.get_node("PlayerHunter")
	else:
		return null

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
	#traps = traps + get_tree().get_nodes_in_group("Lure")
	
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

#return the traps (for this level) of a given type
func get_traps(type):
	return traps_data[type]

#loads data from all traps available in this level
func load_trap_info():
	var traps = {} #traps.json 
	var traps_in_level = {} #traps_by_level.json
	
	#dictionary structury
	traps_data = {
	trap_enum.BUMP:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[]},
	trap_enum.LURE:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[]},
	trap_enum.MISC:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[]},
	trap_enum.VICE:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[]}
	}
	
	#all traps
	var file = File.new()
	file.open("res://resources/json/traps.json",File.READ)
	traps = file.get_as_text()
	file.close()
	traps = parse_json(traps)
	
	#traps in this level
	file.open("res://resources/json/traps_by_level.json",File.READ)
	traps_in_level = file.get_as_text()
	file.close()
	traps_in_level = parse_json(traps_in_level)
	
	#assign the traps for this level to the dictionary
	for type in traps_in_level['Traps'][get_level()]:
		if traps_in_level['Traps'][get_level()][type].size()>= 1:
			for trap in traps_in_level['Traps'][get_level()][type]:
				
				#trap data
				var _type = type 
				var id = int(trap)
				var icon = traps['Traps'][type]['Icon'][id]
				var fear = int(traps['Traps'][type]['Fear'][id])
				var curiosity = int(traps['Traps'][type]['Curiosity'][id])
				var price = int(traps['Traps'][type]['Price'][id])
				var requirements = traps['Traps'][type]['Requirements'][id]
				var oneshot = traps['Traps'][type]['OneShot'][id]
				
				#change the trap type to an enum
				match type:
					"BUMP":
							_type = trap_enum.BUMP
					"LURE":
							_type = trap_enum.LURE
					"MISC":
							_type = trap_enum.MISC
					"VICE":
							_type = trap_enum.VICE
					_:
							_type = trap_enum.NULL
							
				#string to boolean
				match oneshot:
					'true':
						oneshot = true
					'false':
						oneshot = false
				
				#assign data
				traps_data[_type]['ID'].append(id)
				traps_data[_type]['Icon'].append(icon)
				traps_data[_type]['Fear'].append(fear)
				traps_data[_type]['Curiosity'].append(curiosity)
				traps_data[_type]['Price'].append(price)
				traps_data[_type]['OneShot'].append(oneshot)
				traps_data[_type]['Requirements'].append(requirements)