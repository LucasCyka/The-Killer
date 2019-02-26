extends Node2D

"""
	Traps base class.
	All traps will delivery from this class
"""

#the tileset the trap will lay
var tiles = null
var base = null

#constructor
func init(base,tiles):
	self.base = base
	self.tiles = tiles