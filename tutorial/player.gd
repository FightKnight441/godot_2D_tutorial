extends Area2D
signal hit
@export var projectile_scene: PackedScene
@export var speed = 400 # How fast the player will move (pixels/sec).
@export var projectileCoolDown : float = 1.0
@export var currentProjectileCooldown : float = 1.0
var screen_size # Size of the game window.
# Called when the node enters the scene tree for the first time.

func _ready():
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentProjectileCooldown -= delta
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	if Input.is_action_pressed("left_click_fire"):
		if (currentProjectileCooldown <= 0):
			_fire_projectile()

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.stop()
	
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)

	if velocity.x != 0:
		$AnimatedSprite2D.animation = "walk"
		$AnimatedSprite2D.flip_v = false
		# See the note below about the following boolean assignment.
		$AnimatedSprite2D.flip_h = velocity.x < 0
	elif velocity.y != 0:
		$AnimatedSprite2D.animation = "up"
		$AnimatedSprite2D.flip_v = velocity.y > 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false

func _on_body_entered(_body):
	hide() # Player disappears after being hit
	hit.emit()
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)

func _fire_projectile():
	currentProjectileCooldown = projectileCoolDown
	
	var projectile = projectile_scene.instantiate()
	
	# Spawn the bullet at the player's position
	projectile.global_position = global_position

	# Direction from player to mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	projectile.direction = direction  # assuming your projectile script has a `direction` variable

	# Add projectile to the current scene
	get_tree().current_scene.add_child(projectile)
