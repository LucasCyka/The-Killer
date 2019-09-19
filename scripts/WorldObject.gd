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
export var is_oneshot = true

#if it can be activated when someone else is using this object
export var can_activated_when_using = true

#this means that it will cause effects (if activated) when the teen is
#close to the object, without using it.
export var is_detectable = false

export(String) var obj_desc
#sound to be played the AI is using the object normally
export(String) var use_sound
#sound to be played when the ai uses an object that is broken
export(String) var use_broken_sound
#sound to be palyed when the object is activated
export(String) var activated_sound
#icon that will appear when the player hover the object
export(String) var cursor
#the price to use this object
export(int) var price

var current_teen = []
var current_player = null
var is_broken = false
var activated = false
var door_bar

#when a door is locked the player can't pass throught it...
var is_door_locked = false setget set_door_locked
#unless he reduces the door health to zero points
var door_health = 1000 setget set_door_health, get_door_health

#effects this object can cause when activated
var effects = {
	0:[funcref(self,"startle")],
	1:[funcref(self,"turn_off_lights")],
	2:[funcref(self,"break_obj")]
	
}

#initialize
func _ready():
	if is_activable:
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
	
	#progress bar
	area.get_node('DoorProgress').set_min(0)
	area.get_node('DoorProgress').set_max(door_health)
	area.get_node('DoorProgress').set_value(0)
	
func open_door(area):
	if is_door_locked: return 
	
	if area.name == 'DetectionArea' or area.name == 'TreeSight':
		self.frame = 1 
		current_teen.append(area.get_parent())

func set_door_health(value):
	door_health = value
	get_node('DoorDrawing/DoorProgress').set_value(door_health)
	get_node('DoorDrawing/DoorProgress').show()
	
	if door_health == 0:
		if current_player != null:
			current_player.set_attacking_door(false)
			is_broken = true
			if has_node('DoorDrawing'):
				get_node('DoorDrawing').queue_free()
			current_player.door_collision = Vector2(0,0)
			hide()

func get_door_health():
	return door_health

func close_door(area):
	if is_door_locked: 
		self.frame = 0
		return 
		
	if area.name == 'DetectionArea' or area.name == 'TreeSight':
		self.frame = 0
		current_teen.erase(area.get_parent())

#when a teen starts to use the object
func use(teen):
	current_teen.append(teen)
	
	var game = get_parent().get_parent()
	
	#sounds if have any
	if use_sound != "" and not is_broken and current_teen.size() == 1:
		game.audio_system.play_2d_sound(use_sound,global_position)
	elif use_broken_sound != "" and is_broken and current_teen.size() == 1:
		game.audio_system.play_2d_sound(use_broken_sound,global_position)

#when a teen stops using the object
func leave(teen):
	current_teen.remove(current_teen.find(teen))

#trys will activate the effects of this trap
func activate():
	if current_teen != [] and not can_activated_when_using:
		return
		
	for effect in effects[id]:
		effect.call_func()
	if is_oneshot: activated = true
	
	
	#sound effect
	if activated_sound != "":
		var game = get_parent().get_parent()
		game.audio_system.play_2d_sound(activated_sound,global_position)

##Effects##
func startle():
	if current_teen == []:return
	
	var pos = star.get_closest_tile(self.global_position)
	pos = star.get_closest_tile(Vector2(pos.x+75,pos.y))
	
	for teenager in current_teen:
		if teenager.state_machine.check_forced_state('Startled'):
			teenager.state_machine.state_position = pos
			teenager.state_machine.force_state('Startled')
			
			teenager.set_fear(teenager.get_fear()+10,true)
			teenager.set_curiosity(teenager.get_curiosity()+10)

func turn_off_lights():
	var game = get_parent().get_parent()
	game.has_light = false
	game.update_lights(false)
	#TODO: sound effect

func break_obj():
	#print('the object is now broken')
	is_broken = true

func set_door_locked(value):
	is_door_locked = value
	
	if is_door_locked and not is_broken:
		#this collision prevents the player from passing throught the door
		var door_col = get_node("DoorDrawing/DoorCollision")
		door_col.get_node('CollisionShape2D').disabled = false
		if !door_col.is_connected('area_entered',self,'set_door_collision'):
			door_col.connect('area_entered',self,'set_door_collision')
			door_col.connect('area_exited',self,'remove_door_collision')

func set_door_collision(area):
	if area.name == 'DoorCollision':
		var hunter = area.get_parent()
		var hunter_y = hunter.global_position.y
		var hunter_x = hunter.global_position.x
	
		
		if current_player != hunter:
			current_player = hunter
			hunter.set_attacking_door(true)
		
		if self.get_animation() == 'door':
			#vertical collisions
			if hunter_y < self.global_position.y:
				hunter.door_collision = Vector2(0,-1)
			else:
				hunter.door_collision = Vector2(0,1)
		else:
			#horizontal collisions
			if hunter_x < self.global_position.x:
				hunter.door_collision = Vector2(1,0)
			else:
				hunter.door_collision = Vector2(-1,0)
		
func remove_door_collision(area):
	if area.name == 'DoorCollision':
		area.get_parent().door_collision = Vector2(0,0)
		
		var hunter = area.get_parent()
		
		if current_player == hunter:
			current_player = null
			hunter.set_attacking_door(false)





