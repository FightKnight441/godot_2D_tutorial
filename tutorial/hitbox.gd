extends Area2D

#this is the "motion value". When a hitbox is activated, 
#the actor's strength/spirit is multiplied by this value to get the dValue
@export var damageMultiplier: float
#same for status
@export var statusMultiplier: float
#damage type and value
@export var dType: effectData.damageType
@export var dValue: float
#status type and value
@export var sType: effectData.statusType
@export var sValue: float
#force Value and direction
#if fValue is <0, direction will be set to coordinates and used to move targets outward
@export var fValue: float
@export var fDirection: Vector2

@export var groups: Array[String]
@export var ignoreId: Array[int]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func _on_body_entered(body):
	if (!ignoreId.has(body.get_instance_id())):
		for x in groups:
			if(body.is_in_group(x)):
				if (fValue <0):
					fDirection = global_position
				body.deliver_hit(dType, dValue, sType, sValue, fValue, fDirection, groups)

func activate(strength : float, spirit : float):
	dValue = strength * damageMultiplier
	sValue = spirit * statusMultiplier
	ignoreId.clear()
	$CollisionShape2D.disabled = false

func deactivate():
	ignoreId.clear()
	$CollisionShape2D.set_deferred("disabled", true)
