extends Control

"""
	Controls the loading screen.
"""

var path
var loader = ResourceLoader
var current_scene = null

onready var progress = $ProgressBar

func init(path,current_scene):
	self.path = path
	self.current_scene = current_scene
	
	loader = loader.load_interactive(path)
	#progress bar
	progress.set_max(loader.get_stage_count())
	set_process(true)

#loads the level
func _process(delta):
	if loader == null:
		set_process(false)
		return
	
	var error = loader.poll()
	
	if error == ERR_FILE_EOF:
		#the loading is complete
		load_scene()
		set_process(false)
		loader = null
		return
		
	progress.set_value(loader.get_stage()+1)

#add a new scene and free the current one.
func load_scene():
	if star.tile_node != null: star.clear()
	var root = get_tree().get_root()
	current_scene.queue_free()
	root.add_child(loader.get_resource().instance())
	get_tree().set_current_scene(get_tree().get_root().get_node("Main"))
	











