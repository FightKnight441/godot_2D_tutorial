extends Player2D

@export var projectile_scene: PackedScene
@export var shield_scene: PackedScene
@export var projectileCoolDown : float = 1.0
@export var invulnerableTimer : float = 0.0
@export var currentProjectileCooldown : float = 1.0



var shield
var shieldInUse : bool = false
var shieldStamina : float = 10.0

var rng = RandomNumberGenerator.new()

func _ready():
	maxHealth = 120
	health = 120
	maxStamina = 120
	stamina = 120
	defense = 12
	resistance = 12
	strength = 12
	spirit = 12
	speed = 400
	
	shield = shield_scene.instantiate()
	add_child(shield)
	shield_hide()
	

	hide()
	$AnimatedSprite2D.play()
	self.start(Vector2(500,500))
	
func _process(delta):
	super._process(delta)
	if (shieldInUse):
		add_stamina(-shieldStamina)
		
func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
func deliver_hit(dType : effectData.damageType, dValue : float,
	 			_sType : effectData.statusType, _sValue : float,
	 			fValue : float, fDirection : Vector2, groups : Array[String]):
		if(!invulnerable):
			super.deliver_hit(dType, dValue, _sType, _sValue, fValue, fDirection, groups)
			$invulnerabilityTimer.start()
			

	
	
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
	
