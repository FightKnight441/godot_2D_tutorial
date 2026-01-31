class_name Enemy2D extends Actor2D

signal enemy_death

var states : Dictionary[String, int] = {# states the enemy can be in
	"STANDING" : 00, "RUNNING" : 01, "WALKING" : 02, #nuetral states
	"KNOCKBACK" : 10, "KNOCKDOWN" : 11, "GETTINGUP" : 12, "FLINCHING" : 13, #getting hit states
	"NODDINGOFF" : 20, "SLEEPING" : 21, "PARALYZED" : 22, "STUNNED" : 23, #impaired status states
	"KNOCKEDOUT" : 30, "DYING" : 31, "DEAD" : 32,
	"ATTACKING" : 40, 
}  #0hp states
	
var goals : Dictionary[String, int] = {
	"IDLE" : 900, "WANDER" : 901, "SEARCH" : 902,
	"CHASE" : 910, "APPROACH" : 911, 
	"ATTACK" : 920, "BUFF" : 921, "FIXCONDITION" : 922,
	"AVOID" : 931, "ESCAPE" : 932, "REPOSITION" : 933
}

var state : int = states["STANDING"] #current state enemy is in
var goal : int = goals["IDLE"] # current goal enemy has
var target : Vector2
var moveDirection : Vector2 = Vector2.ZERO
var aiActive = false

var playerSpotted = false
var deathFadeMaxTime: float

#TODO: drop table????

func _ready():
	target = global_position
	self.add_to_group("mobs")
	#sprite = $AnimatedSprite2D
	#collision = $CollisionShape2D
	sprite.animation = "STANDING"
	sprite.play()
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.frame_changed.connect(_on_frame_changed)
	sprite.animation_changed.connect(_on_animation_changed)
	$Sight.body_entered.connect(_on_body_sight)
	$SearchTimer.timeout.connect(_on_search_timeout)
	$SearchTimer.start()
	$DeathFadeTimer.timeout.connect(_on_death_timeout)
	deathFadeMaxTime = $DeathFadeTimer.get_wait_time()
	
	
func _physics_process(delta : float):
	perform_friction(delta)
	moveDirection = Vector2.ZERO
		
	process_goal()
	determine_state()
	process_state()
	
	move_and_slide() 

func process_goal():
	if (goal == goals["IDLE"]):
		process_idle_goal()
	elif (goal == goals["WANDER"]):
		process_wander_goal()
	elif (goal == goals["SEARCH"]):
		process_search_goal()
	elif (goal == goals["CHASE"]):
		process_chase_goal()
	elif (goal == goals["APPROACH"]):
		process_approach_goal()
	elif (goal == goals["ATTACK"]):
		process_attack_goal()
	elif (goal == goals["BUFF"]):
		process_buff_goal()
	elif (goal == goals["FIXCONDITION"]):
		process_fixcondition_goal()
	elif (goal == goals["AVOID"]):
		process_avoid_goal()
	elif (goal == goals["ESCAPE"]):
		process_escape_goal()
	elif (goal == goals["REPOSITION"]):
		process_reposition_goal()
		
func determine_state():
	if (state == states["STANDING"]):
		standing_determine_state()
	elif (state == states["RUNNING"]):
		running_determine_state()
	elif (state == states["WALKING"]):
		walking_determine_state()
	elif (state == states["KNOCKBACK"]):
		knockback_determine_state()
	elif (state == states["KNOCKDOWN"]):
		knockdown_determine_state()
	elif (state == states["GETTINGUP"]):
		gettingup_determine_state()
	elif (state == states["FLINCHING"]):
		flinching_determine_state()
	elif (state == states["KNOCKEDOUT"]):
		knockedout_determine_state()
	elif (state == states["DYING"]):
		dying_determine_state()
	elif (state == states["DEAD"]):
		dead_determine_state()

func standing_determine_state():
	if moveDirection != Vector2.ZERO:
				$AnimatedSprite2D.animation = "RUNNING"
				$AnimatedSprite2D.play()
				state = states["RUNNING"]
				
func running_determine_state():
	if moveDirection == Vector2.ZERO:
				$AnimatedSprite2D.animation = "STANDING"
				$AnimatedSprite2D.play()
				state = states["STANDING"]
				
func walking_determine_state():
	pass
func knockback_determine_state():
	pass
func knockdown_determine_state():
	pass
func gettingup_determine_state():
	pass
func flinching_determine_state():
	pass
func knockedout_determine_state():
	pass
func dying_determine_state():
	pass
func dead_determine_state():
	pass
	
func process_state():
	if (state == states["STANDING"]):
		standing_process_state()
	elif (state == states["RUNNING"]):
		running_process_state()
	elif (state == states["WALKING"]):
		walking_process_state()
	elif (state == states["KNOCKBACK"]):
		knockback_process_state()
	elif (state == states["KNOCKDOWN"]):
		knockdown_process_state()
	elif (state == states["GETTINGUP"]):
		gettingup_process_state()
	elif (state == states["FLINCHING"]):
		flinching_process_state()
	elif (state == states["KNOCKEDOUT"]):
		knockedout_process_state()
	elif (state == states["DYING"]):
		dying_process_state()
	elif (state == states["DEAD"]):
		dead_process_state()

#the XXX_process_state() functions are here to have a common state capable of
#calling the appropriate functions for those states
func standing_process_state():
	grounded = true
	flip_sprite_with_facing()
	run_toward_target(moveDirection, 1.0)
		
func running_process_state():
	grounded = true
	run_toward_target(moveDirection, 1.0)
	flip_sprite_with_facing()

		
func walking_process_state():
	pass
func knockback_process_state():
	pass
func knockdown_process_state():
	pass
func gettingup_process_state():
	pass
func flinching_process_state():
	pass
func knockedout_process_state():
	pass
func dying_process_state():
	pass
func dead_process_state():
	pass

func process_idle_goal():
	pass
func process_wander_goal():
	if (global_position.distance_to(target) <= speed):
		#set new target
		target = (global_position +  (Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()*speed*5))
func process_search_goal():
	pass
func process_chase_goal():
	moveDirection = global_position.direction_to(target).normalized()
	if (global_position.distance_to(target) <= speed):
		if (playerSpotted):
			goal = goals["ATTACK"]
		else:
			goal = goals["IDLE"]
func process_approach_goal():
	pass
func process_attack_goal():
	pass
func process_buff_goal():
	pass
func process_fixcondition_goal():
	pass
func process_avoid_goal():
	pass
func process_escape_goal():
	pass
func process_reposition_goal():
	pass
	


func _on_search_timeout():
	if (goal == goals["WANDER"] || 
		goal == goals["SEARCH"] || 
		goal == goals["IDLE"]):
		$Sight.set_deferred("monitoring", true)
		playerSpotted = false

func _on_body_sight(body):
	if (body.is_in_group("player")):
		target = body.global_position
		facing = global_position.direction_to(body.global_position)
		goal = goals["CHASE"]
		playerSpotted = true
		$Sight.set_deferred("monitoring", false)

func _on_frame_changed():
	super._on_frame_changed()
	
func _on_death_timeout():
	queue_free()
	
func on_health_depleted():
	goal = goals["IDLE"]
	state = states["FLINCHING"]
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.animation = "FLINCHING"
	$AnimatedSprite2D.play()
	enemy_death.emit()
	
