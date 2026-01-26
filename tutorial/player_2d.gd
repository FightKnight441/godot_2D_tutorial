class_name Player2D extends Actor2D

signal status_change


const states : Dictionary[String, int] = {# states the players can be in
	"STANDING" : 00, "RUNNING" : 01, "WALKING" : 02, #nuetral states
	"KNNOCKBACK" : 10, "KNOCKDOWN" : 11, "GETTINGUP" : 12, "FLINCHING" : 13, #getting hit states
	"NODDINGOFF" : 20, "SLEEPING" : 21, "PARALYZED" : 22, "STUNNED" : 23, #impaired status states
	"KNOCKEDOUT" : 30, "DYING" : 31, "DEAD" : 32}  #0hp states
	#Note Player entensions should begin adding states at 100+
var state : int = states["STANDING"] #current state player is in
var moveDirection : Vector2 = Vector2.ZERO

func _ready():
	$InvulnerabilityTimer.timeout.connect(_on_invlun_timeout)

func _process(_delta : float):
	if Input.is_action_pressed("move_right"):
		moveDirection.x += 1
	if Input.is_action_pressed("move_left"):
		moveDirection.x -= 1
	if Input.is_action_pressed("move_down"):
		moveDirection.y += 1
	if Input.is_action_pressed("move_up"):
		moveDirection.y -= 1
		
	determine_state()
	process_state()
	
func deliver_hit(dType : effectData.damageType, dValue : float,
	 			_sType : effectData.statusType, _sValue : float,
	 			fValue : float, fDirection : Vector2, groups : Array[String]):
		if(!invulnerable):
			super.deliver_hit(dType, dValue, _sType, _sValue, fValue, fDirection, groups)
			$InvulnerabilityTimer.start()
			
func add_health(value : float):
	super.add_health(value)
	status_change.emit()
	
func add_stamina(value: float):
	super.add_stamina(value)
	status_change.emit()
	
func on_health_depleted():
	state = states["DYING"] #TODO: dying will likely be more complicated, we can change this
	perform_knocked_out()
	
func _on_invlun_timeout():
	$InvulnerabilityTimer.stop()
	$InvulnerabilityTimer.wait_time = 1.0
	invulnerable = false
	
#this function takes in several peieces of information to determine what state we need to be in next
func determine_state():
	match state:
		states["STANDING"]:
			if moveDirection != Vector2.ZERO:
				$AnimatedSprite2D.animation = "Run"
				$AnimatedSprite2D.play()
				state = states["RUNNING"]
		states["RUNNING"]:
			if moveDirection == Vector2.ZERO:
				$AnimatedSprite2D.animation = "Stand"
				$AnimatedSprite2D.play()
				state = states["STANDING"]


	#this function calls the appropriate functions for our current state and inputs
func process_state():
	match state:
		states["STANDING"]:
			flip_sprite_with_facing()
			#the order of these actions techincally describes 
			#the precedent with which these actions are determiend should two inputs be hit on the same frame
			#Eventually we're gonna want an input buffer to hold our inputs for some 
			#(adjsutable?) number of frames before it determines the output
			#also, some actions may want to happen while held instead of on leading edge. IDK how we want to fix that
			if Input.is_action_pressed("dash_action"):
				perform_dash_action()
			elif Input.is_action_just_pressed("interact_action", false):
				perform_interact_action()
			elif Input.is_action_just_pressed("super_action", false):
				perform_super_action()
			elif Input.is_action_just_pressed("special_action", false):
				perform_special_action()
			elif Input.is_action_just_pressed("attack_action", false):
				perform_normal_action()

		states["RUNNING"]:
			flip_sprite_with_facing()
			run_toward_target(moveDirection, speed)
			if Input.is_action_pressed("dash_action"):
				perform_dash_action()
			elif Input.is_action_just_pressed("interact_action", false):
				perform_interact_action()
			elif Input.is_action_just_pressed("super_action", false):
				perform_super_action()
			elif Input.is_action_just_pressed("special_action", false):
				perform_special_action()
			elif Input.is_action_just_pressed("attack_action", false):
				perform_normal_action()
			
			
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
	
func perform_knocked_out():
	#TODO: dying will likely be more complicated, we can change this
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
	$AnimatedSprite2D.animation = "Dead"
