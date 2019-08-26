extends AnimatedSprite

"""
	A world object is anything on the map that the player can interact with.
	
	It can be a trap when activated or an easter egg.

"""

enum TYPE{
	CHAIR,
	DOOR,
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
#if it can be activated when someone else is using this object
export var can_activated_when_using = true

#this means that it will cause effects (if activated) when the teen is
#close to the object, without using it.
export var is_detectable = false

export(String) var obj_name
export(String) var obj_desc
#sound to be played the AI is using the object normally
export(String) var use_sound
#sound to be played when the ai uses an object that is broken
export(String) var use_broken_sound
#sound to be palyed when the object is activated
export(String) var activated_sound

var current_teen = []
var is_broken = false

#effects this object can cause when activated
var effects = {
	0:[funcref(self,"startle")],
	1:[funcref(self,"turn_off_lights")],
	2:[funcref(self,"break_obj")]
	
}

#initialize
func _ready():
	if is_clickable:
		#create a button mask for this object
		var mask = BitMap.new()
		var image = get_sprite_frames().get_frame(get_animation(),0).get_data()
		mask.create_from_image_alpha(image,0.1) #0.1
		$Button.texture_click_mask = mask
		$Button.rect_global_position = Vector2($Button.rect_global_position.x-25,$Button.rect_global_position.y)
	
		
	else:
		$Button.hide()
	
	if type == TYPE.DOOR:
		init_door()
	
func _process(delta):
	pass

#initialize this door
func init_door():
	var area = load("res://scenes/DoorDrawing.tscn").instance()
	area.connect('area_entered',self,'open_door')
	area.connect('area_exited',self,'close_door')
	add_child(area)
	area.global_position = self.global_position
	
func open_door(area):
	if area.name == 'DetectionArea' or area.name == 'TreeSight':
		self.frame = 1 

func close_door(area):
	if area.name == 'DetectionArea' or area.name == 'TreeSight':
		self.frame = 0

#when a teen starts to use the object
func use(teen):
	current_teen.append(teen)
	
	#TODO: sounds if have any

#when a teen stops using the object
func leave(teen):
	current_teen.remove(current_teen.find(teen))

#trys will activate the effects of this trap
func activate():
	if current_teen != [] and not can_activated_when_using:
		return
		
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

func break_obj():
	#TODO: sounds if any
	print('the object is now broken')
	is_broken = true
	