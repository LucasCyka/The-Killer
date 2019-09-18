extends TileMap

"""
	Indoor detection. This script will tell if something is indoor (inside 
	buildings) or not.
"""

#world nodes
onready var game = get_parent().get_parent()

var teenagers = []

func _ready():
	teenagers = game.get_teenagers()
	init_teen_indoor_detection()

func _input(event):
	if event is InputEventMouseMotion:
		var traps = game.get_placed_traps()
		if traps == []: return
		set_traps_indoor(traps)

#initialize the indoor system for the teenager
func init_teen_indoor_detection():
	#entering area
	for tile in get_used_cells_by_id(1):
		var detection = preload("res://scenes/IndoorDrawing.tscn").instance()
		detection.get_child(0).connect("area_entered",self,"set_teen_indoor",[true])
		add_child(detection)
		detection.global_position = map_to_world(tile)
	
	#exiting area
	for tile in get_used_cells_by_id(2):
		var detection = preload("res://scenes/IndoorDrawing.tscn").instance()
		detection.get_child(0).connect("area_entered",self,"set_teen_indoor",[false])
		add_child(detection)
		detection.global_position = map_to_world(tile)
	
	for teenager in teenagers:
		#use the old way to check if a teenager is inside a building on the start
		var pos = teenager.kinematic_teenager.global_position
		var closest = game.get_closest_tile_by_id(self,pos,0,20)
			
		#he's close, thus indoor
		if closest != pos:
			teenager.is_indoor = true
		else: teenager.is_indoor = false

#sets if a teen is inside or outside a building
func set_teen_indoor(area,value):
	if area.name == 'InteriorDection':
		area.get_parent().is_indoor = value

"""Commented for yet another optmization. this code was very slow. 
It looked through hundreds of tiles for the closest one to the player.
#sets if a teen is inside or outside a building
func set_teen_indoor(teenager):
	#game.get_closest_tile() may be too slow
	var pos = teenager.kinematic_teenager.global_position
	var closest = game.get_closest_tile(self,pos,20)
		
	#he's close, thus indoor
	if closest != pos:
		teenager.is_indoor = true
	else: teenager.is_indoor = false
"""

func set_player_indoor(player):
	var pos = player.kinematic_player.global_position
	
	var closest = game.get_closest_tile_by_id(self,pos,0,20)
	
	#the player's close, thus indoor
	if closest != pos:
		player.set_is_indoor(true)
	else: player.set_is_indoor(false)

#change the indoor/outdoor variable on traps
func set_traps_indoor(traps):
	for trap in traps:
		var pos = trap.get_node("Texture").global_position
		var closest = game.get_closest_tile_by_id(self,pos,0,20)
		
		#the trap's close, thus indoor
		if closest != pos:
			trap.set_is_indoor(true)
		else: trap.set_is_indoor(false)












