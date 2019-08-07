extends Node

"""
	Audio system. Will play sounds and music in the game.
"""

onready var sounds2d = $Sound2D
onready var sounds = $Sound
onready var musics = $Music

#store 2d tracks in queue to be played
var queues_2d = {
	'track_node':'times'
}

#initialize
func _ready():
	settings.connect("audio_changed",self,"update_volume_db")
	
	update_volume_db()

#update the volume for each sound/music
func update_volume_db():
	var music = $Music.get_children()
	var sound = $Sound.get_children() + $Sound2D.get_children()
	var background = $Background.get_children()
	
	for track in music:
		track.set_volume_db(settings.get_music_db())
		
	for track in sound:
		track.set_volume_db(settings.get_sound_db())
		
	for track in background:
		track.set_volume_db(settings.get_background_db())

#play a 2d sound effect at a given location
#if queue == true it will wait for the current sound to end before 
#starting the other
func play_2d_sound(sound,at,queue=true):
	var track = sounds2d.get_node(sound)
	
	if not track.is_playing():
		track.global_position = at
		track.play()
	elif queue:
		_queue_2d_sound(track,at)

#play a sound effect.
func play_sound(sound):
	var track = sounds.get_node(sound)
	track.play()

#play a music from the track
func play_music(music):
	var track = musics.get_node(music)
	track.play()

#queue 2d sound effects to be played a given amount of times
func _queue_2d_sound(track,at,playing=false):
	if not playing:
		if queues_2d.keys().find(track) == -1:
			queues_2d[track] = 1
			track.connect('finished',self,'_queue_2d_sound',[track,at,true])
		else:
			queues_2d[track] += 1
	else:
		track.global_position = at
		track.play()
		queues_2d[track] -= 1
		
		if queues_2d[track] == 0:
			track.disconnect('finished',self,'_queue_2d_sound')
			queues_2d.erase(track)
		
	










