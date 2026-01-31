class_name Actor2D extends CharacterBody2D

signal health_hit_0
signal stamina_hit_0

var sprite
var collision

#defense damage reduction coefficient, 
#this is to adjust the reduction number so that defense is soft bounded
#where we want it to be value wise
#DDRC = 0.01 results in 6~95%, 30~71%, 100~30%, 120 ~22.5%, 205~10%, 300~5% damage
const DDRC : float = 0.01

@export var maxHealth : float = 30
@export var health : float = 30
var invulnerable = false

@export var maxStamina : float = 30
@export var stamina : float = 30
@export var staminaRegenRate : float = 6.0
var staminaRegen = true

@export var defense : float = 6 #not yet used to reduce incoming physical damage
@export var resistance : float = 6 #not yet used to reduce incoming energy damage
@export var strength : float = 6 #not yet used to increase physical damage
@export var spirit : float = 6 #not yet used to incerase special ability effects

@export var speed : float = 100 # How fast the player will move (pixels/sec).
@export var friction : float = 10 #1/x of speed per second or something liek that
@export var grounded = true
var facing : Vector2 = Vector2.LEFT

#the list of active hitboxes should only include hitboxes 
var activeHitboxList : Array[String]
#the list of hitboxes, aniamtion, and frame that a hitbox is active during
@export var hitboxActiveFrameList : Array[Dictionary]

#Do we want poise for flinch/knockback, 
#do we want it to work as thresholds or as a bar to be depleted? 🤔
#@export var maxPoise : float = 1.0
#@export var poise : float = 1.0

#DIVISOR for amount of force received from a hitbox
@export var forceReduction : float = 1.0

#mulitplier for each damage type. A higher number receives more damage
@export var vulnerability : Dictionary[effectData.damageType, float] = {
	effectData.damageType.NONE : 1.0,
	effectData.damageType.SLASH : 1.0,
	effectData.damageType.STRIKE : 1.0,
	effectData.damageType.PIERCE : 1.0,
	effectData.damageType.SONIC : 1.0,
	effectData.damageType.FIRE : 1.0,
	effectData.damageType.ICE : 1.0,
	effectData.damageType.ELECTRIC : 1.0
}

func _physics_process(delta: float) -> void:
	move_and_slide() 
	perform_friction(delta)

#gather data from a hitbox and use it to determine the effect of the hitbox
#This is expected to be overridden in some cases, but generally used
func deliver_hit(dType : effectData.damageType, dValue : float,
	 			_sType : effectData.statusType, _sValue : float,
	 			fValue : float, fDirection : Vector2, groups : Array[String]):
	if (invulnerable == true):
		return
	var do_damage = false
	for x in groups:
		if self.is_in_group(x):
			do_damage = true
	if do_damage:
		var damage : float = 0.0
		var reduction : float = 1.0
		#damage reduction formula. Def/Res will never reduce damage to 0
		#only give a damage reduction the higher defense goes
		#technically negative def/res is a damage increase
		if (dType == effectData.damageType.SLASH ||
			effectData.damageType.STRIKE ||
			effectData.damageType.PIERCE): #physical damage types
			reduction = 1 - ((DDRC*defense)/(sqrt(pow(DDRC*defense, 2) + 1)))
			
		elif (dType == effectData.damageType.SONIC ||
			effectData.damageType.FIRE ||
			effectData.damageType.ICE ||
			effectData.damageType.ELECTRIC): #energy damage types
			reduction = 1 - ((DDRC*resistance)/(sqrt(pow(DDRC*resistance, 2) + 1)))
		
		#Note, damage type of NONE is unmitigated
		damage = dValue * reduction * vulnerability[dType]
		damage = floor(damage) #keep damage an integer for simplicity
		#make sure damage is a positive number. Don't want to accidentally heal somehow
		#might remove this to allow heals to work the same as hits
		#the clarity of "deliver_hit" with a positve value and "deliver heal" with a positive value may or may not be worth it
		#removing this check would allow hitboxes to have negative damage in order to heal
		if (damage >= 1):
			add_health(-1.0 *damage)
		else:
			print("damage = ", damage, " That's negative damage, buddy; how'd ya go and do that, pal?")
		
		#do force movement
		if (fValue < 0):
			#move outward from hitbox origin, given in fDirection
			velocity += floor(fValue / forceReduction * (fDirection - global_position).normalized())
		else:
			#move in direction specified, regardless of orientation compared to hitbox
			velocity += ((fValue / forceReduction) * fDirection.normalized()).floor()
	
func flip_sprite_with_facing():
	if (facing.x < 0):
		$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.flip_h = true

func early_process_common(delta : float):
	if (staminaRegen): 
		add_stamina(staminaRegenRate * delta) #recover stamina at normal rate
		

func perform_friction(delta : float):
	#slow down due to friction
	if (grounded): #ground friction
		velocity = velocity * (1 - friction * delta)
	else: #air friction not ignored
		velocity = velocity * (1 - friction * 0.01 * delta)
		
	
func deactivate_hitboxes():
	var deactivate = true
	for x in activeHitboxList.size():
		for i in hitboxActiveFrameList:
			if (i["hitbox"] == activeHitboxList[x] &&
				i["animation"] == $AnimatedSprite2D.animation &&
				i["frame"] == $AnimatedSprite2D.frame):
					deactivate = false
		if (deactivate):
			find_child(activeHitboxList[x], false, true).deactivate()
			activeHitboxList.remove_at(x)
		
func activate_hitboxes():
	for x in hitboxActiveFrameList:
		if (x["animation"] == $AnimatedSprite2D.animation 
			&& x["frame"] == $AnimatedSprite2D.frame):
			find_child(x["hitbox"], false, true).activate(strength, spirit)
			activeHitboxList.append(x["hitbox"])
			
func _on_frame_changed():
	deactivate_hitboxes()
	activate_hitboxes()
	
func _on_animation_changed():
	deactivate_hitboxes()
	activate_hitboxes()
	
func _on_animation_finished():
	pass
	
func health_depleted():
	pass
	
func stamina_depleted():
	pass
	
func add_health(value : float):
	health = clampf(health + value, 0, maxHealth)
	if (health <=0):
		health_hit_0.emit()
		health_depleted()
		
func add_stamina(value : float):
	stamina += value
	if (stamina < 0):
		stamina_hit_0.emit()
		stamina_depleted()
	elif (stamina > maxStamina):
		stamina = maxStamina
		
func run_toward_target(target : Vector2, scalar : float):
	var velocityAddition = scalar * speed * target.normalized()
	facing = target.normalized()
	var angleOfVelocity = velocity.angle_to(Vector2.RIGHT)
	var rotatedVelocity = velocity.rotated(angleOfVelocity)
	var rotVelocityAddition = velocityAddition.rotated(angleOfVelocity)
	
	if (rotVelocityAddition.x > 0): #moving in same direction of current velocity
		if ((scalar * speed) - rotatedVelocity.x <= 0):#already over top speed
			rotVelocityAddition.x = 0
		else: #take our additional velocity in the direction of current velocity and scale it down to a maximum of adding up to top speed
			rotVelocityAddition.x = clampf(rotVelocityAddition.x, 0, (scalar * speed) - rotatedVelocity.x)
		
	velocityAddition = rotVelocityAddition.rotated(-angleOfVelocity)
	velocity += velocityAddition
	
	
func get_maxHealth():
	return maxHealth
func set_maxHealth(newValue):
	maxHealth = newValue
	
func get_health():
	return health
func set_health(newValue):
	health = newValue
	
func get_maxStamina():
	return maxStamina
func set_maxStamina(newValue):
	maxStamina = newValue
	
func get_stamina():
	return stamina
func set_stamina(newValue):
	maxStamina = newValue

func get_defense():
	return defense
func set_defense(newValue):
	defense = newValue
	
func get_resistance():
	return resistance
func set_resistance(newValue):
	resistance = newValue
	
func get_strength():
	return strength
func set_strength(newValue):
	strength = newValue
	
func get_spirit():
	return spirit
func set_spirit(newValue):
	spirit = newValue
	
func get_speed():
	return speed
func set_speed(newValue):
	speed = newValue

func get_forceReduction():
	return forceReduction
func set_forceReduction(newValue):
	forceReduction = newValue
	
func get_vulnerability(dType : effectData.damageType):
	return vulnerability[dType]
func set_vulnerability(newValue, dType : effectData.damageType):
	vulnerability[dType] = newValue
	
func get_invulnerable():
	return invulnerable
func set_invulnerable(newValue : bool):
	invulnerable = newValue
