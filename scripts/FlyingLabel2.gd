extends AnimationPlayer

"""
	A label that will fly up along the y axis towards an ui element
	before disappearing.
"""

var speed

#initialize
func init(text,i_pos,f_pos,speed=1.5):
	var animation = Animation.new()
	animation.add_track(Animation.TYPE_VALUE,0)
	animation.set_length(1.5)
	animation.set_name('anim')
	animation.track_set_path(0,'FlyingLabel/Label:rect_position')
	
	add_animation('anim',animation)
	get_animation('anim').track_insert_key(0,0,i_pos)
	get_animation('anim').track_insert_key(0,1.5,f_pos)
	self.speed = speed
	connect("animation_finished",self,'exit')
	$Label.set_text(text)
	
func _ready():
	pass
	play('anim',-1,speed)

func exit(anim):
	call_deferred('free')
