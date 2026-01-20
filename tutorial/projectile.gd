extends Area2D

func _ready():
	var projectile = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = projectile.pick_random()
	$AnimatedSprite2D.play()

@export var speed : float = 500.0
var direction : Vector2 = Vector2.RIGHT  # Set when spawned
var projectileTimeOut : float

func _process(delta: float) -> void:
	position += direction * speed * delta
	# Remove if off screen (optional safety)
	if not get_viewport_rect().has_point(global_position):
		#print("Debug: Projectile Deleted")
		queue_free()

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

# Upon colliding mob, delete mob and projectile
func _on_body_entered(body: Node) -> void:
	#print("Debug: Projectile collided with", body)
	if body.is_in_group("mobs"):
		#body.queue_free()
		queue_free()
