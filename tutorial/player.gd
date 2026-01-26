extends CharacterBody2D
signal hit
signal status_change

@export var projectile_scene: PackedScene
@export var shield_scene: PackedScene
@export var projectileCoolDown : float = 1.0
@export var invulnerableTimer : float = 0.0
@export var currentProjectileCooldown : float = 1.0
var screen_size # Size of the game window.
enum {STANDING, RUNNING, DODGING, ATTACKING, GUARDING, DYING} # states the players can be in
var state = STANDING #current state player is in

# Called when the node enters the scene tree for the first time.

@export var maxHealth : float = 120
@export var health : float = 120
@export var maxStamina : float = 120
@export var stamina : float = 120
@export var defense : float = 12
@export var resistence : float = 12
@export var strength : float = 12
@export var spirit : float = 12
@export var speed : float = 400 # How fast the player will move (pixels/sec).

@onready var main = get_parent()

var shield
var shieldInUse : bool = false

var rng = RandomNumberGenerator.new()

func _ready():
	shield = shield_scene.instantiate()
	add_child(shield)
	shield_hide()
	
	screen_size = get_viewport_rect().size
	hide()
	$AnimatedSprite2D.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#remove time from timers
	currentProjectileCooldown -= delta
	invulnerableTimer -= delta
	replenish_stamina(delta)
	
	#Controls
	velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1
	#Actions
	if Input.is_action_pressed("left_click_fire"):
		if (currentProjectileCooldown <= 0):
			_fire_projectile()
	if Input.is_action_just_pressed("right_click_fire"):
		shield_use()
		shieldInUse = true
	if Input.is_action_just_released("right_click_fire"):
		shield_hide()
		shieldInUse = false

	#dertermine state transition based on user inputs/
	#and game circumstances
	if health <= 0:
		state = DYING
	
	match state:
		STANDING:
			if velocity != Vector2.ZERO:
				state = RUNNING
		RUNNING:
			if velocity == Vector2.ZERO:
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
			
			if Input.is_action_pressed("left_click_fire"):
				if (currentProjectileCooldown <= 0):
					_fire_projectile()
		RUNNING:
			$AnimatedSprite2D.animation = "Run"
			if velocity.length() > 0:
				velocity = velocity.normalized() * speed
				if velocity.x < 0:
					$AnimatedSprite2D.flip_h = false
				else:
					$AnimatedSprite2D.flip_h = true
			
			if Input.is_action_pressed("left_click_fire"):
				if (currentProjectileCooldown <= 0):
					_fire_projectile()
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
			hit.emit()
			
	status_change.emit()
	
	move_and_slide()
	#position += velocity * delta
	#position = position.clamp(Vector2.ZERO, screen_size)
	
	if (invulnerableTimer >0):
		
		var intensity = 1 + (0.353 * ((Time.get_ticks_msec() % 250)/250.0))
		$AnimatedSprite2D.self_modulate = Color(intensity, intensity/2, intensity/2)
	else:
		$AnimatedSprite2D.self_modulate = Color(1,1,1)

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func deliver_hit(dType, dValue, sType, sValue, fValue, fDirection, groups):
	if (groups.has("player") and invulnerableTimer <= 0): 
		health -= dValue
		#status_change.emit()
		invulnerableTimer = 1

func add_health(amount):
	health += amount
	
	if(health > maxHealth):
		health = maxHealth

func replenish_stamina(delta):
	
	var shieldStaminaUse : int
	var staminaRegenAmount : int = 5
	
	#print("Shield in use? : ", shieldInUse)
	
	if shieldInUse:
		shieldStaminaUse = 10
	else:
		shieldStaminaUse = 0
	
	var calculatedStaminaChange = stamina + ((staminaRegenAmount - shieldStaminaUse) * delta)
	
	if calculatedStaminaChange >= maxStamina:
		stamina = maxStamina
	else:
		stamina = calculatedStaminaChange
	

func _on_body_entered(_body):
	#hide() # Player disappears after being hit
	#hit.emit()
	#if (invulnerableTimer <= 0): 
		#health -= 20
		#status_change.emit()
		#invulnerableTimer = 1
		pass

func _fire_projectile():
	currentProjectileCooldown = projectileCoolDown
	
	var projectile = projectile_scene.instantiate()
	projectile.userStrength = strength
	projectile.userSpirit = spirit
	# Spawn the bullet at the player's position
	projectile.global_position = global_position

	# Direction from player to mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()

	projectile.direction = direction  # assuming your projectile script has a `direction` variable

	# Add projectile to the current scene
	get_tree().current_scene.add_child(projectile)

func shield_use():
	if stamina >= 0: # show shield when RMB held
		#print("Debug: shield_use()")
		shield.show()
		shield.toggleCollision()
	else:
			print("Debug: No stamina: ", stamina)
			shield_hide()

func shield_hide(): # hide shield when RMB released
	#print("Debug : shield_hide()")
	shield.hide()
	shield.toggleCollision()
	#shield.set_deferred("disabled", true)

func get_mouse_direction():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	return direction
	
