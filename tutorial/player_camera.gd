extends Camera2D

func _ready():
	zoom.x = 2.0
	zoom.y = 2.0

func _process(_delta : float):
	
	# set camera to player's position each frame
	position = get_node("../Player_Default").global_position
	
	# scroll up/down to Zoom
	if Input.is_action_just_pressed("scroll_up"):
		zoom.x +=.1
		zoom.y +=.1
	if Input.is_action_just_pressed("scroll_down"):
		zoom.x -=.1
		zoom.y -=.1
	
	
