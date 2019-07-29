extends Node

"""
	Audio system. Will play sounds and music in the game.
"""

onready var sounds2d = $Sound2D
onready var sounds = $Sound
onready var musics = $Music

#TODO: solve the problem with duplicated sounds

#initialize
func _ready():
	settings.connect("audio_changed",self,"update_volume_db")
	
	update_volume_db()

#update the volume for each sound/music
func update_volume_db():
	var music = $Music.get_children()
	var sound = $Sound.get_children() + $Sound2D.get_children()
	
	for track in music:
		track.set_volume_db(settings.get_music_db())
		
	for track in sound:
		track.set_volume_db(settings.get_sound_db())

#play a 2d sound effect at a given location
func play_2d_sound(sound,at):
	var track = sounds2d.get_node(sound)
	track.global_position = at
	track.play()

#play a sound effect.
func play_sound(sound):
	var track = sounds.get_node(sound)
	track.play()

#play a music from the track
func play_music(music):
	var track = musics.get_node(music)
	track.play()




