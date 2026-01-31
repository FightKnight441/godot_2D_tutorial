extends Enemy2D

var frameGroup : int = randi_range(0,30)

func _ready():
	sprite = $AnimatedSprite2D
	collision = $CollisionShape2D
	super._ready()
	maxHealth = 200
	health = 200
	maxStamina = 120
	stamina = 120
	staminaRegenRate = 18
	defense = 30
	resistance = 24
	strength = 64
	spirit = 16
	speed = 250
	
	aiActive = true
	
func _physics_process(delta):
	super._physics_process(delta)
	
	
func process_idle_goal():
	if (aiActive):
		if (Engine.get_frames_drawn() % 30 == frameGroup):
			goal = goals["WANDER"]

func process_attack_goal():
	if (state != states["ATTACKING"]):
		state = states["ATTACKING"]
		sprite.set_deferred("animation", "TUSK_ATTACK_STARTUP")
		sprite.play()
		
	
func _on_animation_finished():
	super._on_animation_finished()
	if (sprite.animation == "TUSK_ATTACK_STARTUP"):
		sprite.set_deferred("animation", "TUSK_ATTACK_ACTIVE")
		sprite.play()
		velocity += facing * speed * 5
	if (sprite.animation == "TUSK_ATTACK_ACTIVE"):
		sprite.set_deferred("animation", "TUSK_ATTACK_RECOVERY")
		sprite.play()
		
	if (sprite.animation == "TUSK_ATTACK_RECOVERY"):
		sprite.set_deferred("animation", "STANDING")
		sprite.play()
		state = states["STANDING"]
		goal = goals["WANDER"]
