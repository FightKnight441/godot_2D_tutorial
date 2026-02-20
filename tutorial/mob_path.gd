extends Path2D

func draw_beyond_screen():
	return
	var viewport = get_viewport_rect()
	
	var offset = 50
	
	var top_left = Vector2((viewport.position.x - offset), (viewport.position.y - offset))
	print(top_left)
	var top_right = Vector2((viewport.end.x + offset),(viewport.position.y - offset))
	print(top_right)
	var bottom_right = Vector2(viewport.end.x + offset, viewport.end.y + offset)
	print(bottom_right)
	var bottom_left = Vector2(viewport.position.x - offset , viewport.end.y + offset)
	print(bottom_left)
	
	curve.set_point_position(0, top_left)
	curve.set_point_position(1, top_right)
	curve.set_point_position(2, bottom_right)
	curve.set_point_position(3, bottom_left)
	curve.set_point_position(4, top_left)
