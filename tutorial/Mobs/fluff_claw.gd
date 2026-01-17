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

@export var wanderDistance = 1000.0
@export var target : Vector2
@export var invulnerableTimer : float = 1.0
@export var searchCooldownMs : float = 2000
var playerSpotted = false

enum {WANDER, CHASE, ATTACK, EVADE}
var goal = WANDER
enum {STANDING, RUNNING, DODGING, ATTACKING, GUARDING, FLINCHING, DYING} # states the players can be in
var state = STANDING #current state player is in

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = global_position
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finish)
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$Sight.area_entered.connect(_on_player_sight)
	$SearchTimer.timeout.connect(_on_timeout)
	$SearchTimer.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if health <= 0:
		state = DYING
		
	invulnerableTimer -= delta

	
	#identifyGoal
	match goal:
		WANDER: 
			if (global_position.distance_to(target) <= 300):
				#set new target
				target = (global_position +  (Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()*wanderDistance)).clamp(Vector2.ZERO, get_viewport_rect().size)
		CHASE:
			if (global_position.distance_to(target) <= 300):
				if (playerSpotted):
					goal = ATTACK
				else:
					goal = WANDER
		ATTACK: 
			#if (global_position.distance_to(target) >= 500 || playerSpotted == false):
				#goal = WANDER
				pass
		EVADE:
			print("How we evade?")
			goal = WANDER
		
	
	
	match state:
		STANDING:
			if (goal == WANDER || goal == CHASE || goal == EVADE):
				state = RUNNING
		RUNNING:
			if (goal == ATTACK):
				linear_velocity = Vector2.ZERO
				state = ATTACKING
		DODGING:
			print("how?")
		ATTACKING:
			#wait for signal to tell us we are done attacking
			pass
		GUARDING:
			print("how?")
	
	
	#perform state logic
	match state:
		STANDING:
			$AnimatedSprite2D.animation = "Stand"

		RUNNING:
			linear_velocity = speed * (target - global_position).normalized()
			$AnimatedSprite2D.animation = "Run"
			$AnimatedSprite2D.play()
			if linear_velocity.x < 0:
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.flip_h = true
			
		DODGING:
			print("howdodgeing?")
		ATTACKING:
			$AnimatedSprite2D.animation = "Pounce"
			if ((target - global_position).x < 0):
				$AnimatedSprite2D.flip_h = false
			else:
				$AnimatedSprite2D.flip_h = true
		GUARDING:
			print("how guard, boy?")
		DYING:
			$AnimatedSprite2D.animation = "Dead"
			# Must be deferred as we can't change physics properties on a physics callback.
			$CollisionShape2D.set_deferred("disabled", true)

			
		
func _on_player_sight(_area):

	if (_area.is_in_group("player")):
		target = _area.global_position
		goal = CHASE
		playerSpotted = true
		$Sight.set_deferred("monitoring", false)


func _on_animation_finish():

	if ($AnimatedSprite2D.animation == "Pounce"):
		state = RUNNING
		goal = WANDER
		

func _on_frame_changed(): 
	if ($AnimatedSprite2D.animation == "Pounce"):
		if ($AnimatedSprite2D.frame == 6):
			linear_velocity = 3 * speed * (target - global_position).normalized()
		if ($AnimatedSprite2D.frame == 7):
			linear_velocity = Vector2.ZERO

func _on_timeout():
			#search for player
		$Sight.set_deferred("monitoring", true)
		playerSpotted = false
