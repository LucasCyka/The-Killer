extends Node2D

"""
	'Common' Singleton.
	I'll put here functions that I use most and are not available on 
	Godot native code.
"""

#order (in natural order) an array of positions according to their distances
#to a given point.
func order_by_distance(positions,point):
	var distances = []
	var final_array = []
	
	for pos in positions:
		distances.append(pos.distance_to(point))
	distances.sort()
	
	for distance in distances:
		for pos in positions:
			if pos.distance_to(point) == distance:
				final_array.append(pos)
				break
				
	return final_array

#place a sprite in a given position and scene
func place_sprite(pos,scene):
	var spr = Sprite.new()
	spr.name = "Spr1"
	spr.set_z_index(10)
	spr.texture = preload("res://icon.png")
	spr.global_position = pos
	scene.add_child(spr)
	





