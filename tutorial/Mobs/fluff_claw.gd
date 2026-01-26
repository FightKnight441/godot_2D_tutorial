extends Actor2D

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

func _init():
	maxHealth = 60
	health = 60
	maxStamina = 60
	stamina = 60
	defense = 6
	resistance = 12
	strength = 30
	spirit = 12
	speed = 300 # How fast the player will move (pixels/sec).

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	target = global_position
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finish)
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$Sight.body_entered.connect(_on_player_sight)
	$SearchTimer.timeout.connect(_on_timeout)
	$SearchTimer.start()
	$DeathFadeTimer.timeout.connect(_on_death_timeout)
	deathFadeMaxTime = $DeathFadeTimer.get_wait_time()
	$InvulnerabilityTimer.timeout.connect(_on_invlun_timeout)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	early_process_common(delta)
	
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
				pass
		EVADE:
			print("How we evade?")
			goal = WANDER

	match state: #identify state transition based on goal
		STANDING:
			if (goal == WANDER || goal == CHASE || goal == EVADE):
				state = RUNNING
		RUNNING:
			if (goal == ATTACK):
				state = ATTACKING
		DODGING:
			print("how?")
		ATTACKING:
			pass
		GUARDING:
			print("how?")
	
	match state: #perform state logic
		STANDING:
			$AnimatedSprite2D.animation = "Stand"
		RUNNING:
			run_toward_target((target - global_position).normalized(), 1.0)
			$AnimatedSprite2D.animation = "Run"
			$AnimatedSprite2D.play()
			flip_sprite_with_facing()
			
		DODGING:
			print("howdodgeing?")
		ATTACKING:
			$AnimatedSprite2D.animation = "Pounce"
			flip_sprite_with_facing()
		GUARDING:
			print("how guard, boy?")
		DYING:
			$AnimatedSprite2D.self_modulate = Color(1.0,1.0,1.0,$DeathFadeTimer.get_time_left()/deathFadeMaxTime)
			
	late_process_common(delta)
	

func deliver_hit(dType, dValue, sType, sValue, fValue, fDirection, groups):
	super.deliver_hit(dType, dValue, sType, sValue, fValue, fDirection, groups)
	if health <= 0:
		state = DYING
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite2D.animation = "Flinch"
		state = FLINCHING
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
		state = DYING
		$AnimatedSprite2D.animation = "Dead"
		$DeathFadeTimer.start()

func _on_frame_changed(): 
	super._on_frame_changed()
	grounded = true
	if ($AnimatedSprite2D.animation == "Pounce"):
		if ($AnimatedSprite2D.frame == 6):
			grounded = false
			run_toward_target((target - global_position).normalized(), 3.0)


func _on_timeout():
			#search for player
	if (goal == WANDER):
		$Sight.set_deferred("monitoring", true)
		playerSpotted = false
