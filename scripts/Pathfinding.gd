extends Node

"""
	DESC:
		Simple A* algorithm implemented in gdscript
"""

#tile map contaiing each tile from the grid.
var tile_node = null
#all astar algorith is already in this node.
var star = null
#all the grid tile's position is stored here.
var grid = []
var grid_real = [] #map to real world
#tile proportions
var tile_size = Vector2(20,20)
#is true if diagonal tiles are connected
var diagonals = true
#this dictionary contains the weight for wich tile. Tiles are represented
#by its ID.
var weight_id = {
	0:1,
	1:5
}

#INITIALIZE
func init(tilemap,tile_size,diagonals):
	tile_node = tilemap
	self.tile_size = tile_size
	self.diagonals = diagonals
	star = AStar.new()
	add_points()
	
#add points to the grid	
func add_points():
	if tile_node != null:
		for tile in tile_node.get_used_cells():
			var _weight = weight_id[tile_node.get_cell(tile.x,tile.y)]
			star.add_point(grid.size(),vector_convert(tile),_weight)
			grid.push_back(tile)
			grid_real.push_back(tile_node.map_to_world(tile))
		connect_points()

#connect neighbour points in the grid
func connect_points():
	for id in range(grid.size()):
		#verifies if theres a tile in each 8 directions.
		var right_id = grid.find(Vector2(grid[id].x+1,grid[id].y))
		var left_id =  grid.find(Vector2(grid[id].x-1,grid[id].y))
		var up_id =  grid.find(Vector2(grid[id].x,grid[id].y-1))
		var down_id =  grid.find(Vector2(grid[id].x,grid[id].y+1))
		var right_up = grid.find(Vector2(grid[id].x+1,grid[id].y-1))
		var right_down = grid.find(Vector2(grid[id].x+1,grid[id].y+1))
		var left_up = grid.find(Vector2(grid[id].x-1,grid[id].y-1))
		var left_down = grid.find(Vector2(grid[id].x-1,grid[id].y+1))
		
		if right_id != -1 and !star.are_points_connected(id,right_id):
			star.connect_points(id,right_id)
		
		if left_id != -1 and !star.are_points_connected(id,left_id):
			star.connect_points(id,left_id)
		
		if up_id != -1 and !star.are_points_connected(id,up_id):
			star.connect_points(id,up_id)
		
		if down_id != -1 and !star.are_points_connected(id,down_id):
			star.connect_points(id,down_id)
		
		if diagonals: #connect diagonal tiles
			if right_up != -1 and !star.are_points_connected(id,right_up):
				star.connect_points(id,right_up)
			
			if right_down != -1 and !star.are_points_connected(id,right_down):
				star.connect_points(id,right_down)
			
			if left_up != -1 and !star.are_points_connected(id,left_up):
				star.connect_points(id,left_up)
			
			if left_down != -1 and !star.are_points_connected(id,left_down):
				star.connect_points(id,left_down)

#remove a point from the grid
func remove_point(tile):
	var point = star.get_closest_point(vector_convert(tile_node.world_to_map(tile)))
	star.remove_point(point)
	
#return the path to a destination
func find_path(from,to):
	var i_point = star.get_closest_point(vector_convert(tile_node.world_to_map(from)))
	var f_point = star.get_closest_point(vector_convert(tile_node.world_to_map(to)))
	
	var path_points3 = star.get_point_path(i_point,f_point)
	var path_points2 = []
	
	#apply positions to the real world
	for position in path_points3:
		path_points2.push_back(vector_convert(position))
		path_points2[path_points2.size()-1] = tile_node.map_to_world(path_points2[path_points2.size()-1])
		path_points2[path_points2.size()-1].x += (tile_size.x/2)
		path_points2[path_points2.size()-1].y += (tile_size.y/2)
		
	return path_points2
	
#converts a vector3 to vector2 and vice versa.
func vector_convert(vec):
	var final_vec = null
	#verifies the operation type
	if typeof(vec) == TYPE_VECTOR2: final_vec = Vector3(vec.x,0,vec.y)
	elif typeof(vec) == TYPE_VECTOR3: final_vec = Vector2(vec.x,vec.z)
	else: final_vec = Vector3(0,0,0)
	
	return final_vec

#clear all the points from the grid
func clear():
	star.clear()
	tile_node = null
	grid.clear()
	grid_real.clear()

#gives the closest point to a given position
func get_closest_tile(position):
	var tile = self.star.get_closest_point(vector_convert(tile_node.world_to_map(position)))
	
	var closest = self.star.get_point_position(tile)
	
	return tile_node.map_to_world(vector_convert(closest))

#get all neighbours a tile has or [] if it has no tiles connected
func get_neighbours(position):
	var tile = self.star.get_closest_point(vector_convert(tile_node.world_to_map(position)))

	var connections_ids = self.star.get_point_connections(tile)
	tile = self.star.get_point_position(tile)
	#theres something wrong with the map_to_world/world_to_map_function
	#this hack is a fix to it

	if connections_ids.size() == 0: return []
	else:
		var connections_positions = []
		#convert to map positions
		for id in connections_ids:
			connections_positions.push_back(self.star.get_point_position(id))
	
		#convert to 2d world positions
		for position in range(connections_positions.size()):
			connections_positions[position] = tile_node.map_to_world(vector_convert(connections_positions[position]))
		
		return connections_positions

#get all neighbours a tile has or [] if it has no tiles connected
#the difference here is that the this functions takes a map position instead
#of a world position.
func get_neighbours2(position):
	var tile = self.star.get_closest_point(vector_convert(position))

	var connections_ids = self.star.get_point_connections(tile)
	tile = self.star.get_point_position(tile)
	#theres something wrong with the map_to_world/world_to_map_function
	#this hack is a fix to it

	if connections_ids.size() == 0: return []
	else:
		var connections_positions = []
		#convert to map positions
		for id in connections_ids:
			connections_positions.push_back(self.star.get_point_position(id))
	
		#convert to 2d world positions
		for position in range(connections_positions.size()):
			connections_positions[position] = tile_node.map_to_world(vector_convert(connections_positions[position]))
		
		return connections_positions

#will increase the weight scale for all tiles of the given id
func increase_tile_weight(position):
	var tile = self.star.get_closest_point(vector_convert(tile_node.world_to_map(position)))
	var current_weight = self.star.get_point_weight_scale(tile)
	self.star.set_point_weight_scale(tile,current_weight+1)

#sets the weight scale for a tile in a given position
func set_tile_weight(position,weight):
	var tile = self.star.get_closest_point(vector_convert(tile_node.world_to_map(position)))
	self.star.set_point_weight_scale(tile,weight)

"""
#DEBUG ONLY
func _ready():
	pass
	
	init(get_tree().get_root().get_child(5).get_node("pathTile"))
	var debug_path = find_path(get_tree().get_root().get_child(5).get_node("DebugFrom").global_position,get_tree().get_root().get_child(5).get_node("DebugTo").global_position)
	print(debug_path)
	
	#draw a path for debugging
	for position in debug_path:
		var dot = Sprite.new()
		dot.texture = preload("res://prototype/dot.png")
		dot.global_position = position
		get_tree().get_root().get_child(5).add_child(dot)
"""
