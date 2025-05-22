extends Path2D

func draw_around_screen():
	var viewport = get_viewport_rect()
	
	var top_left = viewport.position
	print(top_left)
	var top_right = Vector2(viewport.end.x,viewport.position.y)
	print(top_left)
	var bottom_right = viewport.end
	print(top_left)
	var bottom_left = Vector2(viewport.position.x, viewport.end.y)
	print(top_left)
	
	curve.set_point_position(0, top_left)
	curve.set_point_position(1, top_right)
	curve.set_point_position(2, bottom_right)
	curve.set_point_position(3, bottom_left)
	curve.set_point_position(4, top_left)
