extends Node

"""
	Teenager screaming state
	
	When screaming, a teenager can alert others nearby.
"""

signal finished
signal entered

var base
var teenager
var game
var teen_pos
var avoidant_tile = null

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.base.teenager.state_animation = true
	self.teenager = base.teenager
	self.game = base.teenager.get_parent().get_parent()
	
	#custom balloon over the teen's head
	self.base.teenager.update_thinking_balloon(false,['screaming'])
	self.base.teenager.is_talking = false
	self.base.teenager.is_thinking = false
	
	#search for avoidant tile from time to time
	var timer = Timer.new()
	timer.name = 'AvoidantTimer'
	timer.wait_time = 1 #increase this if you are having performance issues
	add_child(timer)
	timer.connect('timeout',self,'_search_avoidant_tile')
	timer.start()
	
	emit_signal("entered")
	
func update(delta):
	if base == null:
		return
		
	teen_pos = teenager.global_position
	var player = get_tree().get_nodes_in_group("Player")
	
	if player == []:
		base.force_state('Panic')
		base = null
		return
	else:
		if player[0].global_position.distance_to(teen_pos) <30:
			#the player is too close...
			return
		else:
			#check if the teen can escape
			if avoidant_tile != null:
				base.force_state('Escaping')
				base = null
				return

#check if the teenager can arrive in a given position and avoid the player
func is_path_free(pos):
	#the path the teen must walk
	var path = star.find_path(teenager.global_position,pos)
	
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

#This will make the AI search for a new avoidant tile.
#this can't be called very often since searching for avoidant tiles
#is very performance heavy.
func _search_avoidant_tile():
	avoidant_tile = get_avoidant_tile()

#destructor
func exit():
	avoidant_tile = null
	if has_node("AvoidantTimer"):
		get_node("AvoidantTimer").queue_free()
	
	emit_signal("finished")