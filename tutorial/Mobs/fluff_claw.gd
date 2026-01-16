extends RigidBody2D

@export var maxHealth : float = 60
@export var health : float = 60
@export var maxStamina : float = 60
@export var stamina : float = 60
@export var defense : float = 2
@export var resistence : float = 12
@export var strength : float = 30
@export var spirit : float = 12
@export var speed : float = 300 # How fast the player will move (pixels/sec).

@export var target : Vector2
@export var invulnerableTimer : float = 1.0
@export var searchCooldown : float = 1.0

enum {WANDER, CHASE, ATTACK, EVADE}
var goal = WANDER
enum {STANDING, RUNNING, DODGING, ATTACKING, GUARDING, DYING} # states the players can be in
var state = STANDING #current state player is in

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = global_position
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		state = DYING
		
	invulnerableTimer -= delta
	
	#match goal:
		#WANDER: 
			#target
	
	
	
	match state:
		STANDING:
			#if velocity != Vector2.ZERO:
				state = RUNNING
		RUNNING:
			#if velocity == Vector2.ZERO:
				state = STANDING
		DODGING:
			print("how?")
		ATTACKING:
			print("how?")
		GUARDING:
			print("how?")
	
	
	#perform state logic
	match state:
		STANDING:
			$AnimatedSprite2D.animation = "Stand"
			

		RUNNING:
			$AnimatedSprite2D.animation = "Run"
			if linear_velocity.x < 0:
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.flip_h = true
			
		DODGING:
			print("howdodgeing?")
		ATTACKING:
			print("how do attack?")
		GUARDING:
			print("how guard, boy?")
		DYING:
			$AnimatedSprite2D.animation = "Dead"
			# Must be deferred as we can't change physics properties on a physics callback.
			$CollisionShape2D.set_deferred("disabled", true)

			
	
	
	
	pass
