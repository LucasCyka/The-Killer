extends AnimatedSprite

"""
	A world object is anything on the map that the player can interact with.
	
	It can be a trap when activated or an easter egg.

"""

export var id = 0
export var activable = false

#effects this object can cause when activated
var effects = {
	0:[funcref(self,"startle")],
	
}

#initialize
func _ready():
	#TODO: load json data
	pass

func startle(teenager):
	pass
	