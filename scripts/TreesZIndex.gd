extends TileMap

"""
	This script should be attrached to tilemap having the trees1.tres tileset.
	It will spawn areas2D that control the z drawing of trees.
"""

#initialize
func _ready():
	if get_parent().get_parent().debug_mode:
		#it will spend things a bit
		return
	
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(20,10)
	
	#each tree will have its area 2D connecting to a signal when someone
	#is close. 
	for tree in get_used_cells():
		var tree_control = load("res://scenes/TreesDrawing.tscn").instance()
		tree_control.init(tree,self)
		
		add_child(tree_control)
		
		"""
		#jesus christ what a mess
		var area2d = Area2D.new()
		add_child(area2d)
		var col = CollisionShape2D.new()
		col.set_shape(shape)
		area2d.add_child(col)
		
		area2d.connect("area_entered",self,"area_entered",[tree])
		area2d.connect("area_exited",self,"area_exited",[tree])
		
		area2d.global_position = Vector2(map_to_world(tree).x+25,map_to_world(tree).y+10)
		"""
		
""" Moved this to a proper scene for optmization.
#check if is the player/AI if so then change its z-index by changing the tile
func area_entered(area,tree):
	if area.name == 'DetectionArea': #AI
		#this increase the z-index of a tree without messing with the ones
		#bellow it
		if get_cell(tree.x,tree.y+1) == INVALID_CELL:
			set_cell(tree.x,tree.y,1)
		else: set_cell(tree.x,tree.y,2)

	elif area.name == 'SightArea': #Player
		pass
	else: return
	
func area_exited(area,tree):
	if area.name == 'DetectionArea': #AI
		set_cell(tree.x,tree.y,0)
	elif area.name == 'SightArea': #Player
		pass
	else: return
	
"""










