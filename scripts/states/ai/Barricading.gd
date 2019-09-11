extends Node

"""
	Teenager barricading state
"""

signal finished
signal entered

var base
var kinematic_teenager
var game
var building_tiles
var building_tile
var last_path_free = null
var last_path_pos = null
var last_current_pos = null
var arrived = false
var door = null
var doors = null
var timer = null
var escape_point = null
var escape_object = null

func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.speed += 10 
	self.base.teenager.saw_player = true
	self.base.teenager.state_animation = false
	self.base.teenager.custom_animation = base.get_node('Panic')
	self.kinematic_teenager = base.teenager
	self.game = base.teenager.get_parent().get_parent()
	self.doors = game.get_doors()
	self.escape_point = game.get_escaping_point(base.teenager.get_position())
	self.escape_object = game.get_escape_object(base.teenager.get_position())
	
	if is_building_free():
		#create the timer that will check from time to time if the teen
		#can escape the level
		timer = preload("res://scenes/CustomTimer.tscn").instance()
		add_child(timer)
		timer.stop()
		timer.name = 'CheckTimer'
		timer.wait_time = 10
		timer.one_shot = false
		timer.connect('timeout',self,'check_escape')
		
		
	emit_signal("entered")
	
func update(delta):
	if base == null: return
	base.teenager.call_into_escaping()
	
	if game.get_current_mode() == game.MODE.HUNTING:
		#when the player is too close from the teenager
		var player = game.get_player()
		var dis = player.global_position.distance_to(kinematic_teenager.global_position)
		
		if dis < 30:
			base.force_state('Cornered')
			return

	
	if building_tile == null:
		#print('go escaping')
		base.teenager.is_escaping = true
		base.teenager.is_barricading = false
		base.force_state('Escaping')
		return
	
	if door == null:
		for _door in doors:
			if _door.current_teen.find(base.teenager) != -1:
				door = _door
				_door.is_door_locked = true
				break
				
	if arrived:
		#TODO: check if there's a telephone nearby to use, if so
		#go to the "calling the cops" state.
		if timer.is_stopped():
			timer.start()
		if game.get_current_mode() == game.MODE.HUNTING:
			var player = game.get_player()
			self.base.teenager.custom_animation = base.get_node('Shock')
			#keep facing the player
			var dir = player.global_position
			dir = dir - base.teenager.kinematic_teenager.global_position
			dir = dir.normalized()
			dir = dir.round()
				
			#for some reason godot is returning '-0' sometimes... why?
			if dir.x == -0: dir.x = 0
			if dir.y == -0: dir.y = 0
				
			#prevent from look at diagonals, since there are not diagonal
			#animations yet.
			if not abs(dir.x) == abs(dir.y):
				base.teenager.facing_direction = dir
		else:
			base.force_state('Escaping')
		return
		
		
	if kinematic_teenager.walk(building_tile):
		arrived = true
	else:
		pass
		"""
		if game.get_current_mode() == game.MODE.HUNTING:
			#when the player is too close from the teenager
			var player = game.get_player()
			var dis = player.global_position.distance_to(kinematic_teenager.global_position)
			
			if dis < 30:
				base.force_state('Cornered')
				return
		"""
			
			

	
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
func is_building_free():
	if building_tiles == null: 
		building_tiles = game.get_indoor_detection()
		building_tiles = common.convert_to_world(building_tiles.get_used_cells(),building_tiles)
		building_tiles = common.order_by_distance(building_tiles,kinematic_teenager.global_position)
	
	var last_tile = null
	for tile in building_tiles:
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

#check if he can escape again
func check_escape():
	var player = game.get_player()
	if player == null: 
		return
	if base == null: return
	
	var dis = player.global_position.distance_to(kinematic_teenager.global_position)
	if dis >= 250:
		#check if he can escape on escape objects
		if not base.get_node('Escaping').tried_escape_object:
			if is_path_free(escape_object.global_position):
				base.force_state('Escaping')
				return
		
		if is_path_free(escape_point):
			base.force_state('Escaping')

func exit():
	if base.is_forced_state:
		base._on_routine = false
	else: base._on_routine = true
	if has_node('CheckTimer'):
		get_node('CheckTimer').stop()
		get_node('CheckTimer').queue_free()
	
	base.teenager.speed -= 10 
	building_tile = null
	building_tiles = null
	last_path_free = null
	last_path_pos = null
	door = null
	arrived = false
	base.teenager.custom_animation = null
	base = null
	emit_signal("finished")