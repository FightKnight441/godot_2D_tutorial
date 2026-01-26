extends Node2D

func _on_body_entered(_body):
	if(_body.name != "Player"):
		pass
	_body.add_health(10)
	get_parent().queue_free()
	pass
