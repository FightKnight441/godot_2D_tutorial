@abstract class_name Actor2D extends CharacterBody2D

signal health_hit_0
signal stamina_hit_0

@export var maxHealth : float = 30
@export var health : float = 30
@export var maxStamina : float = 30
@export var stamina : float = 30

@export var defense : float = 6 #not yet used to reduce incoming physical damage
@export var resistance : float = 6 #not yet used to reduce incoming energy damage
@export var strength : float = 6 #not yet used to increase physical damage
@export var spirit : float = 6 #not yet used to incerase special ability effects

@export var speed : float = 100 # How fast the player will move (pixels/sec).

#Do we want poise for flinch/knockback, 
#do we want it to work as thresholds or as a bar to be depleted? 🤔
#@export var maxPoise : float = 1.0
#@export var poise : float = 1.0

#DIVISOR for amount of force received from a hitbox
@export var forceReduction : float = 1.0

#mulitplier for each damage type. A higher number receives more damage
@export var vulnerability = {
	effectData.damageType.NONE: 1.0,
	effectData.damageType.SLASH: 1.0,
	effectData.damageType.STRIKE: 1.0,
	effectData.damageType.PIERCE: 1.0,
	effectData.damageType.SONIC: 1.0,
	effectData.damageType.FIRE: 1.0,
	effectData.damageType.ICE: 1.0,
	effectData.damageType.ELECTRIC: 1.0
}

#gather data from a hitbox and use it to determine the effect of the hitbox
#This is expected to be overridden in some cases, but generally used
func deliver_hit(dType : effectData.damageType, dValue : float,
	 			_sType : effectData.statusType, _sValue : float,
	 			fValue : float, fDirection : Vector2, groups : Array[String]):
	var do_damage = false
	for x in groups:
		if self.is_in_group(x):
			do_damage = true
	if do_damage:
		add_health(-1.0 * dValue * vulnerability[dType])
		velocity += (fValue / forceReduction) * fDirection.normalized()
	
func add_health(value : float):
	health += value
	if (health <0):
		health = 0
		health_hit_0.emit()
	elif (health > maxHealth):
		health = maxHealth
		
func add_stamina(value : float):
	stamina += value
	if (stamina <0):
		stamina = 0
		stamina_hit_0.emit()
	elif (stamina > maxStamina):
		stamina = maxStamina
		
func add_directional_velocity(target : Vector2, scalar : float):
	velocity += scalar * speed * target.normalized()
	
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
