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

func _input(event):
	if event is InputEventMouseMotion:
		var traps = game.get_placed_traps()
		if traps == []: return
		set_traps_indoor(traps)

#sets if a teen is inside or outside a building
func set_teen_indoor(teenager):
	"""
	var tiles = game.get_indoor_detection()
	var pos = teenager.kinematic_teenager.global_position
	
	for tile in tiles.get_used_cells():
		if tiles.map_to_world(tile).distance_to(pos) <=20:
			teenager.is_indoor = true
			return
	teenager.is_indoor = false
	"""
	
	
	#game.get_closest_tile() may be too slow
	var pos = teenager.kinematic_teenager.global_position
	var closest = game.get_closest_tile(self,pos,20)
		
	#he's close, thus indoor
	if closest != pos:
		teenager.is_indoor = true
	else: teenager.is_indoor = false

func set_player_indoor(player):
	var pos = player.kinematic_player.global_position
	
	var closest = game.get_closest_tile(self,pos,20)
	
	#the player's close, thus indoor
	if closest != pos:
		player.set_is_indoor(true)
	else: player.set_is_indoor(false)

#change the indoor/outdoor variable on traps
func set_traps_indoor(traps):
	for trap in traps:
		var pos = trap.get_node("Texture").global_position
		var closest = game.get_closest_tile(self,pos,20)
		
		#the trap's close, thus indoor
		if closest != pos:
			trap.set_is_indoor(true)
		else: trap.set_is_indoor(false)

"""OLD CODE CHECKED EVERY FRAME, THIS WAS SLOWING THE GAME DOWN...
func _process(delta):
	#TODO: this is taking too much of the game's performance.
	#change things a bit or remove it completely.
	
	#check if any teenager is close enough to any indoor tile
	for teenager in game.get_teenagers():
		var pos = teenager.kinematic_teenager.global_position
		var closest = game.get_closest_tile(self,pos,20)
		
		#he's close, thus indoor
		if closest != pos:
			teenager.is_indoor = true
		else: teenager.is_indoor = false
		
	#check if there's a trap clouse nough to an indoor tile
	var traps = game.get_placed_traps()
	for trap in traps:
		var pos = trap.get_node("Texture").global_position
		var closest = game.get_closest_tile(self,pos,20)
		
		#the trap's close, thus indoor
		if closest != pos:
			trap.set_is_indoor(true)
		else: trap.set_is_indoor(false)
		
	#check if the player is inside a building
	var player =  game.get_player()
	if player != null:
		player = game.get_player()
		var pos = player.kinematic_player.global_position
		
		var closest = game.get_closest_tile(self,pos,20)
		
		#the trap's close, thus indoor
		if closest != pos:
			player.set_is_indoor(true)
		else: player.set_is_indoor(false)
		
"""










