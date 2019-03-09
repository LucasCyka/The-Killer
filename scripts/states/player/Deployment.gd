extends Node

"""
	Player deployment state
"""

signal finished

var base
var mouse_position
var spawn_points
var is_on_spawn = false

#constructor
func init(base,state_position,state_time):
	self.base = base

func update(delta):
	if base == null:
		return
	
	if spawn_points == null:
		spawn_points = self.base.player.game.enable_spawn_points()
		return
	
	mouse_position = base.player.mouse_position
	
	#create a 'magnetic effect' when the hunter is near spawn points
	for point in spawn_points:
		is_on_spawn = false
		if point.distance_to(mouse_position) < 50:
			base.player.kinematic_player.global_position = Vector2(point.x+10,point.y+10)
			is_on_spawn = true
			break
	
	if not is_on_spawn:
		#move the player around the map if he's not close to any spawn point
		base.player.kinematic_player.global_position = mouse_position

#destructor
func exit():
	emit_signal("finished")