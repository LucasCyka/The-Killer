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

func _process(delta):
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











