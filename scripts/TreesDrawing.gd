extends Area2D

"""
	Controls the way the trees are draw.
"""

var tilemap = null
var tree = null

#initialize
func init(tree,tilemap):
	self.tree = tree
	self.tilemap = tilemap
	
	self.global_position = Vector2(tilemap.map_to_world(tree).x+25,tilemap.map_to_world(tree).y+10)


#check if is the player/AI if so then change its z-index by changing the tile
func area_entered(area):
	if area.name == 'DetectionArea' or area.name == 'TreeSight' or area.name == 'AreaSpot': #AI/Player/Trap
		#this increase the z-index of a tree without messing with the ones
		#bellow it
		if tilemap.get_cell(tree.x,tree.y+1) == tilemap.INVALID_CELL:
			tilemap.set_cell(tree.x,tree.y,1)
		else: tilemap.set_cell(tree.x,tree.y,2)
	
	
	else: return
	
func area_exited(area):
	if area.name == 'DetectionArea' or area.name == 'TreeSight' or area.name == 'AreaSpot':#AI/Player/Trap
		tilemap.set_cell(tree.x,tree.y,0)
	else: return





