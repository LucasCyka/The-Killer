extends AnimatedSprite

"""
	A world object is anything on the map that the player can interact with.
	
	It can be a trap when activated or an easter egg.

"""

enum TYPE{
	CHAIR,
	BED,
	PICNIC,
	CAR,
	TELEPHONE,
	DECORATION
}

export(TYPE) var type = TYPE.DECORATION
export var id = 0
export var owner_id = 0
export var is_activable = false
export var is_usable = false

#this means that it will cause effects (if activated) when the teen is
#close to the object, without using it.
export var is_detectable = false

export(String) var obj_name
export(String) var obj_desc


var current_teen = []
var is_broken = false

#effects this object can cause when activated
var effects = {
	0:[funcref(self,"startle")],
	
}

#initialize
func _ready():
	pass

func _process(delta):
	pass

#trys will activate the effects of this trap
func activate():
	pass

##Effects##
func startle(teenager):
	pass

func broke_obj():
	pass