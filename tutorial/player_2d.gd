class_name Player2D extends Actor2D

signal status_change
signal player_death

var states : Dictionary[String, int] = {# states the players can be in
	"STANDING" : 00, "RUNNING" : 01, "WALKING" : 02, "DASHING" : 03, #nuetral states
	"KNOCKBACK" : 10, "KNOCKDOWN" : 11, "GETTINGUP" : 12, "FLINCHING" : 13, #getting hit states
	"NODDINGOFF" : 20, "SLEEPING" : 21, "PARALYZED" : 22, "STUNNED" : 23, #impaired status states
	"KNOCKEDOUT" : 30, "DYING" : 31, "DEAD" : 32}  #0hp states
	#Note Player entensions should begin adding states at 100+
var state : int = states["STANDING"] #current state player is in
var moveDirection : Vector2 = Vector2.ZERO
var invulnerabilityTime : float = 1.5

func _ready():
	$InvulnerabilityTimer.timeout.connect(_on_invuln_timeout)
	

func _physics_process(delta : float):
	perform_friction(delta)
	moveDirection = Vector2.ZERO
		
	if Input.is_action_pressed("move_right"):
		moveDirection.x += 1
	if Input.is_action_pressed("move_left"):
		moveDirection.x -= 1
	if Input.is_action_pressed("move_down"):
		moveDirection.y += 1
	if Input.is_action_pressed("move_up"):
		moveDirection.y -= 1
		
	determine_state()
	#extensions of this class should implement their own method here 
	#to determine states
	process_state()
	
	move_and_slide() 
	
func deliver_hit(dType : effectData.damageType, dValue : float,
	 			_sType : effectData.statusType, _sValue : float,
	 			fValue : float, fDirection : Vector2, groups : Array[String]):

		super.deliver_hit(dType, dValue, _sType, _sValue, fValue, fDirection, groups)
		if(invulnerable == false):
			$InvulnerabilityTimer.wait_time = invulnerabilityTime
			$InvulnerabilityTimer.start()
			invulnerable = true
			
func add_health(value : float):
	super.add_health(value)
	status_change.emit()
	
func add_stamina(value: float):
	super.add_stamina(value)
	status_change.emit()
	
func on_health_depleted():
	perform_knocked_out()
	
func _on_invuln_timeout():
	$InvulnerabilityTimer.stop()
	$InvulnerabilityTimer.wait_time = 3.0
	$AnimatedSprite2D.self_modulate = Color(1,1,1)
	invulnerable = false
	
#this function takes in several peieces of information to determine what state 
#we need to be in next. It calls several fucntions that can be used to call default
#behavior or ovverriden for more or replaced behavior
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
				$AnimatedSprite2D.animation = "Run"
				$AnimatedSprite2D.play()
				state = states["RUNNING"]
				
func running_determine_state():
	if moveDirection == Vector2.ZERO:
				$AnimatedSprite2D.animation = "Stand"
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

#this function calls the appropriate functions for our current state and inputs
#it only calls process for states defined in Player2D, so children of this
#clas must make their own function to call process for thier individual states
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
	#the order of these actions techincally describes 
	#the precedent with which these actions are determiend should two inputs be hit on the same frame
	#Eventually we're gonna want an input buffer to hold our inputs for some 
	#(adjsutable?) number of frames before it determines the output
	#also, some actions may want to happen while held instead of on leading edge. IDK how we want to fix that
	if Input.is_action_just_pressed("dash_action", false):
		perform_dash_action()
	elif Input.is_action_just_pressed("interact_action", false):
		perform_interact_action()
	elif Input.is_action_just_pressed("super_action", false):
		perform_super_action()
	elif Input.is_action_just_pressed("special_action", false):
		perform_special_action()
	elif Input.is_action_just_pressed("attack_action", false):
		perform_normal_action()
	elif Input.is_action_just_pressed("projectile_action", false):
		perform_projectile_action()
		
func running_process_state():
	grounded = true
	run_toward_target(moveDirection, 1.0)
	flip_sprite_with_facing()
	if Input.is_action_just_pressed("dash_action", false):
		perform_dash_action()
	elif Input.is_action_just_pressed("interact_action", false):
		perform_interact_action()
	elif Input.is_action_just_pressed("super_action", false):
		perform_super_action()
	elif Input.is_action_just_pressed("special_action", false):
		perform_special_action()
	elif Input.is_action_just_pressed("attack_action", false):
		perform_normal_action()
	elif Input.is_action_just_pressed("projectile_action", false):
		perform_projectile_action()
		
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


#essentially an interface for extensions of the Player2D class
#define these in the child classes and they will be called with the appropriate input
func perform_interact_action():
	pass	
func perform_normal_action():
	pass
func perform_special_action():
	pass
func perform_super_action():
	pass
func perform_dash_action():
	pass
func perform_projectile_action():
	pass
	
func perform_knocked_out():
	#TODO: dying will likely be more complicated, we can change this
	state = states["DEAD"] 
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.animation = "Dead"
	player_death.emit()
