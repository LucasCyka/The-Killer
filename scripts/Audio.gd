extends Node

"""
	Audio system. Will play sounds and music in the game.
"""

onready var sounds2d = $Sound2D
onready var sounds = $Sound
onready var musics = $Music
onready var background = $Background

var playlist = [] setget , get_playlist
var is_playing_list = false setget, is_playing_list

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

#return all tracks in game
func get_tracks():
	var tracks = $Music.get_children() + $Sound.get_children() 
	tracks = tracks + $Background.get_children() + $Sound2D.get_children()
	return tracks

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
func play_music(music,solo=true,solo_queue=false):
	var track = musics.get_node(music)
	var tracks = get_tracks()
	tracks.erase(track)
	#TODO: if solo, then stop any other music that is playing
	
	if solo_queue:
		#only start the music when there are not sounds playing
		for _track in tracks:
			if _track.is_playing():
				if not _track.is_connected('finished',self,'play_music'):
					_track.connect('finished',self,'play_music',[music,false,true])
				return
			else:
				if _track.is_connected('finished',self,'play_music'):
					_track.disconnect('finished',self,'play_music')
		
	
	track.play()
	

#play background ambience
func play_background(sound,solo=true):
	var track = background.get_node(sound)
	track.play()
	
	if solo:
		for noise in background.get_children():
			if track != noise and noise.is_playing():
				noise.stop()

#check if there's a background track playing
func is_track_playing(track):
	var tracks = musics.get_children() + sounds.get_children() + sounds2d.get_children() + background.get_children()
	
	for _track in tracks:
		if _track.name == track:
			return _track.is_playing()
	
	return false

#stop a given track
func stop_track(track,fade=false):
	var tracks = musics.get_children() + sounds.get_children() + sounds2d.get_children() + background.get_children()
	
	for _track in tracks:
		if _track.name == track:
			_track.stop()
	
	#TODO: fade music 
	return false

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

#starts a playlist of muscis
func start_play_list(tracks,shuffle=false):
	is_playing_list = true
	if shuffle: tracks.shuffle()
	
	for track in tracks:
		var music = musics.get_node(track)
		playlist.append(music)
		
		if not music.is_connected('finished',self,'_next_playlist'):
			music.connect('finished',self,'_next_playlist',[playlist.size()-1])
	
	playlist[0].play()
	print('starting with: ' + str(playlist[0].name))
	
func _next_playlist(id):
	if id == playlist.size()-1:
		playlist[id].disconnect('finished',self,'_next_playlist')
		stop_play_list()
		return
		
	playlist[id+1].play()
	playlist[id].disconnect('finished',self,'_next_playlist')
	print('next:' + str(playlist[id+1].name) )

#stops any ongoing playlist
func stop_play_list():
	for track in playlist:
		if track.is_connected('finished',self,'_next_playlist'):
			track.disconnect('finished',self,'_next_playlist')
		track.stop()
	playlist.clear()
	is_playing_list = false

func get_playlist():
	return playlist

func is_playing_list():
	return is_playing_list






