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
	TABLE,
	POWER,
	BATHROOM,
	DECORATION
}

export(TYPE) var type = TYPE.DECORATION
export var id = 0
export var owner_id = 0
export var owner_id_2 = 0
export var is_activable = false
export var is_clickable = true

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
	1:[funcref(self,"turn_off_lights")],
	
}

#initialize
func _ready():
	if is_clickable:
		#create a button mask for this object
		var mask = BitMap.new()
		var image = get_sprite_frames().get_frame(get_animation(),0).get_data()
		mask.create_from_image_alpha(image,0.1)
		$Button.texture_click_mask = mask
		$Button.rect_global_position = Vector2($Button.rect_global_position.x-25,$Button.rect_global_position.y)
	else:
		$Button.hide()
		
func _process(delta):
	pass

#when a teen starts to use the object
func use(teen):
	current_teen.append(teen)

#when a teen stops using the object
func leave(teen):
	current_teen.remove(current_teen.find(teen))

#trys will activate the effects of this trap
func activate():
	for effect in effects[id]:
		effect.call_func()

##Effects##
func startle():
	if current_teen == []:return
	
	var pos = star.get_closest_tile(self.global_position)
	pos = star.get_closest_tile(Vector2(pos.x,pos.y+50))
	
	for teenager in current_teen:
		if teenager.state_machine.check_forced_state('Startled'):
			teenager.state_machine.state_position = pos
			teenager.state_machine.force_state('Startled')
			
			teenager.set_fear(teenager.get_fear()+10,true)
			teenager.set_curiosity(teenager.get_curiosity()+10,true)

func turn_off_lights():
	var game = get_parent().get_parent()
	game.has_light = false
	game.update_lights(false)
	#TODO: sound effect

func broke_obj():
	pass