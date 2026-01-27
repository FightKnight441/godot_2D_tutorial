extends Area2D

@export var distanceFromPlayer : int = 100
@onready var player = get_parent()

func _ready():
	var shield = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = shield.pick_random()
	$AnimatedSprite2D.play()
	
func _process(_delta: float) -> void:
	var playerToMouse = get_mouse_direction()
	
	global_position = player.global_position + (playerToMouse * distanceFromPlayer) 
	
	rotation = playerToMouse.angle()

func get_mouse_direction():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - player.global_position).normalized()
	return direction


func _on_body_entered(body: Node) -> void:
	#print("Debug: Projectile collided with", body)
	if body.is_in_group("mobs"):
		if (body is RigidBody2D):
			body.linear_velocity = ((player.global_position - body.global_position).normalized()) * -300
		if (body is CharacterBody2D):
			body.velocity = body.velocity.bounce((-1.0 * player.global_position - body.global_position).normalized())
			body.velocity += ((player.global_position - body.global_position).normalized()) * -1000
		#body.queue_free()

func toggleCollision():
	if ($CollisionShape2D.disabled == true):
		$CollisionShape2D.disabled = false
	else:
		$CollisionShape2D.disabled = true
