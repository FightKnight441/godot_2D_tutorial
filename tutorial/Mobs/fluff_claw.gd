extends CharacterBody2D

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
#@export var invulnerableTimer : float = 0.0
@export var searchCooldownMs : float = 2000
var playerSpotted = false
var deathFadeMaxTime: float

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
	$Sight.body_entered.connect(_on_player_sight)
	$SearchTimer.timeout.connect(_on_timeout)
	$SearchTimer.start()
	$PounceAttack.set_deferred("disabled", true)
	$DeathFadeTimer.timeout.connect(_on_death_timeout)
	deathFadeMaxTime = $DeathFadeTimer.get_wait_time()
	$InvulnerabilityTimer.timeout.connect(_on_invlun_timeout)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
		
	#invulnerableTimer -= delta

	
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
				velocity = Vector2.ZERO
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
			velocity = speed * (target - global_position).normalized()
			$AnimatedSprite2D.animation = "Run"
			$AnimatedSprite2D.play()
			if velocity.x < 0:
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
			if ($AnimatedSprite2D.animation == "Dead"):
				$AnimatedSprite2D.self_modulate = Color(1.0,1.0,1.0,$DeathFadeTimer.get_time_left()/deathFadeMaxTime)
			velocity = Vector2.ZERO
			# Must be deferred as we can't change physics properties on a physics callback.
			

	move_and_slide()
	
	if ($InvulnerabilityTimer.get_time_left() > 0):
		var intensity = 1 + (0.353 * ((Time.get_ticks_msec() % 250)/250.0))
		$AnimatedSprite2D.self_modulate = Color(intensity, intensity/2, intensity/2)
		
		
func deliver_hit(dType, dValue, sType, sValue, fValue, fDirection, groups):
	if (groups.has("mobs") and $InvulnerabilityTimer.get_time_left() <= 0): 
		
		health -= dValue
		$InvulnerabilityTimer.set_wait_time(0.5)
		$InvulnerabilityTimer.start()
		
		if health <= 0:
			state = DYING
			$CollisionShape2D.set_deferred("disabled", true)
			$AnimatedSprite2D.animation = "Flinch"
			$AnimatedSprite2D.play()
			
			
			
func _on_invlun_timeout():
	$AnimatedSprite2D.self_modulate = Color(1,1,1)
			
func _on_death_timeout():
	queue_free()
		
func _on_player_sight(_body):

	if (_body.is_in_group("player")):
		target = _body.global_position
		goal = CHASE
		playerSpotted = true
		$Sight.set_deferred("monitoring", false)


func _on_animation_finish():

	if ($AnimatedSprite2D.animation == "Pounce"):
		state = RUNNING
		goal = WANDER
	if ($AnimatedSprite2D.animation == "Flinch"):
		$AnimatedSprite2D.animation = "Dead"
		$DeathFadeTimer.start()
		
func _on_animation_changed():
	$PounceAttack.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_frame_changed(): 
	if ($AnimatedSprite2D.animation == "Pounce"):
		if ($AnimatedSprite2D.frame == 6):
			velocity = 3 * speed * (target - global_position).normalized()
			$PounceAttack.get_node("CollisionShape2D").set_deferred("disabled", false)
		if ($AnimatedSprite2D.frame == 7):
			velocity = Vector2.ZERO
	else:
		$PounceAttack.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_timeout():
			#search for player
	if (goal == WANDER):
		$Sight.set_deferred("monitoring", true)
		playerSpotted = false
