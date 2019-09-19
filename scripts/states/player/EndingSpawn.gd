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
	self.base.player.is_deployed = true
	
	#search a final tile for the player to spawn
	var tilemap = self.game.get_pathfinding_tile()
	var floor_tiles = tilemap.get_used_cells_by_id(0)
	var player_tile = tilemap.world_to_map(base.player.global_position)
	
	var player_neighbours = []
	
	for tile in range(8):
		for x in range(10):
			if floor_tiles.find(Vector2(player_tile.x+x,player_tile.y)) != -1:
				player_neighbours.append(Vector2(player_tile.x+x,player_tile.y))
			elif floor_tiles.find(Vector2(player_tile.x-x,player_tile.y)) != -1:
				player_neighbours.append(Vector2(player_tile.x-x,player_tile.y))
		
		for y in range(10):
			if floor_tiles.find(Vector2(player_tile.x,player_tile.y+y)) != -1:
				player_neighbours.append(Vector2(player_tile.x,player_tile.y+y))
			elif floor_tiles.find(Vector2(player_tile.x,player_tile.y-y)) != -1:
				player_neighbours.append(Vector2(player_tile.x,player_tile.y-y))
		
		if player_neighbours.size() >= 8:
			break
		
	
	player_neighbours = common.convert_to_world(player_neighbours,tilemap)
	
	final_spawn_position = common.order_by_distance(player_neighbours,base.player.global_position)[0]
	final_spawn_position = star.get_closest_tile(final_spawn_position)
	
	
	#hunting mode
	if self.game.get_current_mode() != game.MODE.HUNTING and !base.player.exiting:
		if self.game.get_current_mode() == game.MODE.WON: return
		if self.game.get_current_mode() == game.MODE.GAMEOVER: return
		self.game.set_current_mode(game.MODE.HUNTING)
	
	#floor_tiles = common.convert_to_world(floor_tiles,tilemap)
		
	#final_spawn_position = common.order_by_distance(floor_tiles,base.player.global_position)[0]
	#final_spawn_position = star.get_closest_tile(final_spawn_position)
	
	
func update(delta):
	if final_spawn_position == null:
		return
	
	#walk to the tile where the player will spawn
	if base.player.walk(final_spawn_position) and not is_spawn:
		set_is_spawn(true)

func input(event):
	pass
	#if Input.is_action_just_pressed("cancel_input"):
	#	transitions()

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