extends Area2D

@export var debug : bool #toggle in inspector to get Debug messages

var lifeTime : int = 5 # seconds that the projectile can live
var speed : float = 1000.0 # speed in pixels of projectile
var direction : Vector2 = Vector2.RIGHT  # default direction set when spawned. Player changed this when firing proj's

var userSpirit : float = 0
var userStrength : float = 0

func _ready():
	$DeathTimer.timeout.connect(_on_timeout) 
	$DeathTimer.start(lifeTime)
	
	var projectile = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = projectile.pick_random()
	$AnimatedSprite2D.play()
	$Hitbox.activate(userStrength, userSpirit)

func _process(delta: float) -> void:
	position += direction * speed * delta

func _on_timeout():
	if debug:
		print("Debug: Projectile timeout")
		
	queue_free()

func _on_body_entered(body: Node) -> void:
	#print("Debug: Projectile collided with", body)
	if body.is_in_group("mobs"):
		queue_free() # delete projectile when colliding with mobs group
