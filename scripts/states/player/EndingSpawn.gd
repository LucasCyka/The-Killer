extends Node

"""
	Hunter EndingSpawn state.
	On this state the hunter will move to clear spot before entering
	the Idle state.
"""

signal finished

var base
var game
var is_spawn = false setget set_is_spawn
var final_spawn_position = null

#constructor
func init(base,state_position,state_time):
	self.base = base
	self.game = base.player.game
	
	#search a final tile for the player to spawn
	var tilemap = self.game.get_pathfinding_tile()
	var floor_tiles = tilemap.get_used_cells_by_id(0)
		
	floor_tiles = common.convert_to_world(floor_tiles,tilemap)
		
	final_spawn_position = common.order_by_distance(floor_tiles,base.player.global_position)[0]
	final_spawn_position = star.get_closest_tile(final_spawn_position)
	
	
func update(delta):
	if final_spawn_position == null:
		return
	
	#walk to the tile where the player will spawn
	if base.player.walk(final_spawn_position) and not is_spawn:
		set_is_spawn(true)

func input(event):
	if Input.is_action_just_pressed("cancel_input"):
		transitions()

func set_is_spawn(value):
	is_spawn = value
	
	if is_spawn:
		transitions()

#detect transitions between states
func transitions():
	### ENDINGSPAWN TO DEPLOYMENT ###
	if not is_spawn:
		base.stack.append(base.get_node("Deployment"))
		exit()
	else:
	### ENDINGSPAWN TO IDLE ###
		base.stack.append(base.get_node("Idle"))
		exit()

func exit():
	emit_signal("finished")