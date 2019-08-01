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

#convert the map positions in an array to world position
func convert_to_world(tiles,tilemap):
	var final_array = []
	
	for tile in tiles:
		final_array.append(tilemap.map_to_world(tile))
	
	return final_array

#place a sprite in a given position and scene
func place_sprite(pos,scene):
	var spr = Sprite.new()
	spr.name = "Spr1"
	spr.set_z_index(10)
	spr.texture = preload("res://icon.png")
	spr.global_position = pos
	scene.add_child(spr)
	
#converts 'value' from string to boolean
func string_to_boolean(value):
	match value:
		'true':
			return true
		'false':
			return false

#used to compare floats
func is_float_equal(fa,fb):
	return abs(fa-fb) < 0.000001
"""
func merge_dict(dict1,dict2):
	for key in dict2:
		dict1[key] = dict2[key]
		pass
"""

#merge or add elements to a dictionary
#dest = existing dictionary
#source = new dictionary
func merge_dict(dest, source):
	for key in source:                     # go via all keys in source
		if dest.has(key):                  # we found matching key in dest
            var dest_value = dest[key]     # get value 
            var source_value = source[key] # get value in the source dict           
            if typeof(dest_value) == TYPE_DICTIONARY:       
                if typeof(source_value) == TYPE_DICTIONARY: 
                    merge_dict(dest_value, source_value)  
                else:
                    dest[key] = source_value # override the dest value
            else:
                dest[key] = source_value     # add to dictionary 
		else:
			dest[key] = source[key]          # just add value to the dest
