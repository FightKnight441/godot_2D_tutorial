extends Area2D


#damage type and value
@export var dType: effectData.damageType
@export var dValue: float
#status type and value
@export var sType: effectData.statusType
@export var sValue: float
#force Value and direction
@export var fValue: float
@export var fDirection: Vector2

@export var groups: Array[String]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_entered(body):
	if(body.is_in_group("player") || body.is_in_group("mobs")):
		body.deliver_hit(dType, dValue, sType, sValue, fValue, fDirection, groups)
