extends Node2D

"""
	Control several aspects of the gameplay.
	Things like game over events, points distribution, world information etc...
"""

#the game has been loaded
signal loaded
signal game_over

enum MODE {
	PLANNING,
	HUNTING,
	PAUSED,
	GAMEOVER
}

#the speed the timer will update the time (in seconds).
const default_speed = 1
const fast_speed = 0.2
const ultra_speed = 0.1
const debug_speed = 0.04

var current_mode = MODE.PLANNING setget set_current_mode, get_current_mode
var last_mode = MODE.PLANNING

#the time in-game stored in minutes. 
export var time = 0 setget set_time, get_time

#Default: 1 minute in-game = 1 second.
var timer_speed = default_speed
var ai_timer_speed = default_speed

#traps on this level
var traps_data = {}

#used to keep track of teenagers speed when changing the game speed.
var teens_speed = {}

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
	#start timer
	init_timer()
	
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
	return $Tiles/Path
	#return $Tiles/Floor

#return walls of buildings in the map
func get_wall_tile():
	#TODO: this will also return some floor tiles, change this later...
	return $Tiles/Buildings

#returns the tilemap for the pathfinding algorithm
func get_pathfinding_tile():
	return $Tiles/Path

#change the current game mode
func set_current_mode(value):
	if current_mode != MODE.GAMEOVER:
		current_mode = value
	
	match current_mode:
		MODE.HUNTING:
			disable_spawn_points()
			ui.lock()
		MODE.PLANNING:
			ui.unlock()
		MODE.GAMEOVER:
			ui.lock()
			disable_spawn_points()
			emit_signal("game_over")
			var player = get_player()
			if player != null:player.queue_free()
		_:
			#the game is paused...
			pass
	"""
	if current_mode == MODE.HUNTING:
		#init the hunting mode
		disable_spawn_points()
		ui.lock()
	elif current_mode == MODE.PLANNING:
		ui.unlock()
	else:
		#the game is paused...
		pass
	"""
	
func get_current_mode():
	return current_mode

#the closest escape point from a teenager
func get_escaping_point(teen_pos):
	var points = common.convert_to_world($Tiles/ExitPoints.get_used_cells(),$Tiles/ExitPoints)
	points = common.order_by_distance(points,teen_pos)
	return points.front()

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

#starts the in-game timer
func init_timer():
	$GameTimer.set_wait_time(timer_speed) #1 minute per second
	$GameTimer.connect("timeout",self,"set_time",[1])
	$GameTimer.start()

#loads data from all traps available in this level
func load_trap_info():
	var traps = {} #traps.json 
	var traps_in_level = {} #traps_by_level.json
	
	#dictionary structury
	traps_data = {
	trap_enum.BUMP:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[],"OnSpot":[],"Walkable":[]},
	trap_enum.LURE:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[],"OnSpot":[],"Walkable":[]},
	trap_enum.MISC:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[],"OnSpot":[],"Walkable":[]},
	trap_enum.VICE:{"ID":[],"Icon":[],"Fear":[],"Curiosity":[],"Price":[],"Requirements":[],"OneShot":[],"OnSpot":[],"Walkable":[]
	}
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
				var oneshot = common.string_to_boolean(traps['Traps'][type]['OneShot'][id])
				var onspot = common.string_to_boolean(traps['Traps'][type]['OnSpot'][id])
				var walkable = common.string_to_boolean(traps['Traps'][type]['Walkable'][id])
				
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
							
				
				#assign data
				traps_data[_type]['ID'].append(id)
				traps_data[_type]['Icon'].append(icon)
				traps_data[_type]['Fear'].append(fear)
				traps_data[_type]['Curiosity'].append(curiosity)
				traps_data[_type]['Price'].append(price)
				traps_data[_type]['OneShot'].append(oneshot)
				traps_data[_type]['Requirements'].append(requirements)
				traps_data[_type]['OnSpot'].append(onspot)
				traps_data[_type]['Walkable'].append(walkable)
				
#change the current timer speed in seconds
func update_time_speed(value):
	$GameTimer.stop()
	$GameTimer.set_wait_time(value)
	timer_speed = value
	$GameTimer.start()
	update_game_speed()

#update the speed of several things in-game. Timers, K-bodies etc...
func update_game_speed():
	var teenagers = get_tree().get_nodes_in_group("AI")
	##Teenagers speed##
	for teen in teenagers:
		var new_speed = teen.base_speed
		var anim_speed = 1
		
		#increase/decrease the speed of the teen according to the timer's
		#speed.
		match timer_speed:
			default_speed:
				anim_speed = 1
				ai_timer_speed = 1
				if teens_speed.keys().find(teen) != -1:
					new_speed = teens_speed[teen]
					teens_speed.erase(teen)
				else:continue
			fast_speed:
				anim_speed = 2
				ai_timer_speed = 2
				teen.teenager_anims.set_speed_scale(2)
				if teens_speed.keys().find(teen) == -1:
					common.merge_dict(teens_speed,{teen:teen.speed})
					new_speed *= 2
				else:
					new_speed = teens_speed[teen]
					new_speed *= 2
			ultra_speed:
				anim_speed = 3
				ai_timer_speed = 3
				teen.teenager_anims.set_speed_scale(3)
				if teens_speed.keys().find(teen) == -1:
					common.merge_dict(teens_speed,{teen:teen.speed})
					new_speed *= 4
				else:
					new_speed = teens_speed[teen]
					new_speed *= 4
			debug_speed:
				anim_speed = 4
				ai_timer_speed = 4
				teen.teenager_anims.set_speed_scale(4)
				if teens_speed.keys().find(teen) == -1:
					common.merge_dict(teens_speed,{teen:teen.speed})
					new_speed *= 6
				else:
					new_speed = teens_speed[teen]
					new_speed *= 6
		
		#kinematic body speed
		teen.speed = new_speed
		#animations speed
		teen.teenager_anims.set_speed_scale(anim_speed)
		
		

func set_time(value):
	time += value
	
	if time / 60 == 24 or time >= 1440:
		#one day has passed, restart the clock
		time = 0
	#print(time)

func get_time():
	return time

func pause_game():
	last_mode = get_current_mode()
	set_current_mode(MODE.PAUSED)
	get_tree().paused = true
	
func resume_game():
	set_current_mode(last_mode)
	get_tree().paused = false
	
