extends RigidBody2D

func _ready():
	var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = mob_types.pick_random()
	$AnimatedSprite2D.play()

@export var maxHealth : float = 120
@export var health : float = 120
@export var maxStamina : float = 120
@export var stamina : float = 120
@export var defense : float = 12
@export var resistence : float = 12
@export var strength : float = 12
@export var spirit : float = 12
@export var speed : float = 400 # How fast the player will move (pixels/sec).


func _on_visible_on_screen_notifier_2d_screen_exited():
	print("Debug: Mob deleted!")
	queue_free()

func _on_body_entered(_body):
	print("Debug: Mob hit!")
	hide() # Player disappears after being hit
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	queue_free()
