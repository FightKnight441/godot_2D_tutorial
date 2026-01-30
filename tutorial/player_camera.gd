extends Camera2D

func _process(_delta : float):
	
	if Input.is_action_just_pressed("scroll_up"):
		zoom.x +=.1
		zoom.y +=.1
	if Input.is_action_just_pressed("scroll_down"):
		zoom.x -=.1
		zoom.y -=.1
