extends Node

"""
	'settings' singleton.
	Will store all player's choice settings. Things like audio volume,
	screen resolution etc...
"""

signal audio_changed

#audio system
var sound_db = 0 setget set_sound_db, get_sound_db
var music_db = 0 setget set_music_db, get_music_db
var background_db = 5 setget set_background_db, get_background_db

func set_sound_db(value):
	sound_db = value
	emit_signal("audio_changed")
	
func get_sound_db():
	return sound_db
	
func set_music_db(value):
	music_db = value
	emit_signal("audio_changed")
	
func get_music_db():
	return music_db
	
func set_background_db(value):
	background_db = value
	emit_signal("audio_changed")

func get_background_db():
	return background_db








