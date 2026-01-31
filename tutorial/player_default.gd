extends Player2D

@export var projectile_scene: PackedScene
@export var shield_scene: PackedScene
var projectileCoolDown : float = 0.5
var currentProjectileCooldown : float = 1.0
var shield
var shieldInUse : bool = false
var shieldStamina : float = 10.0
var invulnerabilityReset = 1.0

var rng = RandomNumberGenerator.new()

func _ready():
	super._ready()
	maxHealth = 120
	health = 120
	maxStamina = 120
	stamina = 120
	staminaRegenRate = 18
	defense = 12
	resistance = 12
	strength = 36
	spirit = 12
	speed = 400
	
	shield = shield_scene.instantiate()
	add_child(shield)
	shield_hide()
	

	hide()
	$AnimatedSprite2D.play()
	#self.start(Vector2(500,500))
	sprite = $AnimatedSprite2D
	collision = $CollisionShape2D
	sprite.animation_finished.connect(_on_animation_finished)
	
func _process(delta):
	
	early_process_common(delta)

	flash_damaged_invuln(delta)
	
func _physics_process(delta):
	currentProjectileCooldown -= delta
	super._physics_process(delta)
	
	if Input.is_action_just_released("right_click_fire"):
		shield_hide()
		shieldInUse = false
	
	if (shieldInUse):
		if (stamina <= 0 || (state != states["STANDING"] && state != states["RUNNING"])):
			shield_hide()
			shieldInUse = false
		else: 
			add_stamina(-shieldStamina * delta)

		
func start(pos):
	position = pos
	show()
	$CollisionShape2D.set_deferred("disabled",  false)
	state = states["STANDING"]
	$AnimatedSprite2D.animation = "Stand"
	$AnimatedSprite2D.play()
	health = maxHealth
	stamina = maxStamina
	
func deliver_hit(dType : effectData.damageType, dValue : float,
	 			_sType : effectData.statusType, _sValue : float,
	 			fValue : float, fDirection : Vector2, groups : Array[String]):
		
		super.deliver_hit(dType, dValue, _sType, _sValue, fValue, fDirection, groups)

func health_depleted():
	perform_knocked_out()
	
func perform_dash_action():
	state = states["DASHING"]
	#run_toward_target(-1.0 * facing, 3.0)
	velocity = -3.0 * facing * speed
	add_stamina(-12)
	$AnimatedSprite2D.animation = "Dodge"
	grounded = false
	invulnerable = true
	staminaRegen = false

			
func perform_special_action():
	shield_use()
	shieldInUse = true
			
func perform_projectile_action():
	if (currentProjectileCooldown <= 0):
			_fire_projectile()
	
func finish_dash_action():
	state = states["STANDING"]
	$AnimatedSprite2D.animation = "Stand"
	$AnimatedSprite2D.play()
	staminaRegen = true
	_on_invuln_timeout()
	
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
		shieldInUse = true
		staminaRegen = false
		add_stamina(-12.0)
	else:
		print("Debug: No stamina: ", stamina)
		shield_hide()

func shield_hide(): # hide shield when RMB released
	#print("Debug : shield_hide()")
	shield.hide()
	shield.toggleCollision()
	shieldInUse = false
	staminaRegen = true
	#shield.set_deferred("disabled", true)

func get_mouse_direction():
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	return direction
	
func _on_frame_changed():
	if ($AnimatedSprite2D.animation == "Dodge"):
		if (sprite.frame == 1):
			grounded = true
	
func _on_animation_finished():
	if ($AnimatedSprite2D.animation == "Dodge"):
		finish_dash_action()
		
