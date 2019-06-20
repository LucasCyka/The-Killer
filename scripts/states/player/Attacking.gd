extends Node

"""
	Hunter attacking state
"""

signal finished

var base
var player
var target
var target_pos
var player_pos
var new_position = Vector2(-500,-500)
var busy = false

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.player = base.player
	self.target = base.player.target
	self.target_pos = self.target.kinematic_teenager.global_position
	self.player_pos = self.base.player.kinematic_player.global_position
	
	#select randomly an animation for this hunter
	var animations = player.player_anims.get_sprite_frames().get_animation_names()
	var num = 0
	
	for animation in animations:
		if animation[0] == str(player.id) and animation.find('Attacking') != -1:
			num += 1
		
	if num == 0:
		push_warning('Attacking animations were not found')
		return
	#final attacking animation id
	self.player.attacking_animation_id = str(int(rand_range(num,num+1)))
	
	
func update(delta):
	if base == null:
		return
	
	#update positions
	target_pos = self.target.kinematic_teenager.global_position
	player_pos = self.base.player.kinematic_player.global_position
	
	#check if the player is close enough to the teenager then attack
	if target_pos.distance_to(player_pos) > 35:
		base.player.walk(target_pos)
		
		#Moving animations
		player.player_anims.play(player.animations_data['Moving'][player.facing_direction]['anim'])
		player.player_anims.set_flip_h(player.animations_data['Moving'][player.facing_direction]['flip'])
		
	else:

		#can only exit this state after killing this teen
		busy = true
		player.facing_direction = Vector2(0,1)
		
		if not player.player_anims.is_connected('animation_finished',self,'exit'):
			player.player_anims.connect('animation_finished',self,'exit')
			player.player_anims.play(str(player.id) + '-Attacking:' + player.attacking_animation_id)
		
			#TODO: move in other directions for different animations
			#move the player one tile up
			var closest = star.get_closest_tile(player.global_position)
			closest.y-=25
			player.global_position = closest
			
			player.attack(target)
			
		
	transitions()
	
func input(event):
	if Input.is_action_just_pressed("ok_input"):
		new_position = base.player.mouse_position

#detect transitions between states
func transitions():
	if busy: 
		#the player can't exit this state right now
		return
	
	if base.player.target == null:
		if new_position != Vector2(-500,-500):
		### ATTACKING TO MOVING ###
			base.stack.append(base.get_node("Moving"))
			base.state_position = new_position
			exit()
		else:
		### ATTACKING TO IDLE ###
			base.stack.append(base.get_node("Idle"))
			exit()
	
#destructor
func exit():
	busy = false
	if player.player_anims.is_connected('animation_finished',self,'exit'):
		player.player_anims.disconnect('animation_finished',self,'exit')
		base.stack.append(base.get_node("Idle"))
		player.target = null
		
	emit_signal("finished")
	
