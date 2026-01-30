class_name Enemy2D extends Actor2D

signal enemy_death

const states : Dictionary[String, int] = {# states the enemy can be in
	"STANDING" : 00, "RUNNING" : 01, "WALKING" : 02, #nuetral states
	"KNNOCKBACK" : 10, "KNOCKDOWN" : 11, "GETTINGUP" : 12, "FLINCHING" : 13, #getting hit states
	"NODDINGOFF" : 20, "SLEEPING" : 21, "PARALYZED" : 22, "STUNNED" : 23, #impaired status states
	"KNOCKEDOUT" : 30, "DYING" : 31, "DEAD" : 32}  #0hp states
	
const goals : Dictionary[String, int] = {
	"IDLE" : 900, "WANDER" : 901, "SEARCH" : 902,
	"CHASE" : 910, "APPROACH" : 911, 
	"ATTACK" : 920, "BUFF" : 921, "FIXCONDITION" : 922,
	"AVOID" : 931, "ESCAPE" : 932, "REPOSITION" : 933
}

var state : int = states["STANDING"] #current state enemy is in
var goal : int = goals["IDLE"] # current goal enemy has
var target : Vector2
var moveDirection : Vector2 = Vector2.ZERO

var playerSpotted = false
var deathFadeMaxTime: float

#TODO: drop table????

func _ready():
	target = global_position
	$AnimatedSprite2D.play()
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finish)
	$AnimatedSprite2D.frame_changed.connect(_on_frame_changed)
	$Sight.body_entered.connect(_on_player_sight)
	$SearchTimer.timeout.connect(_on_search_timeout)
	$SearchTimer.start()
	$DeathFadeTimer.timeout.connect(_on_death_timeout)
	deathFadeMaxTime = $DeathFadeTimer.get_wait_time()
	
func _physics_process(delta : float):
	perform_friction(delta)
	moveDirection = Vector2.ZERO
		
	determine_goal()
	determine_state()
	process_state()
	
	move_and_slide() 

func determine_goal():
	pass
	
func determine_state():
	pass
	
func process_state():
	pass


func _on_search_timeout():
	pass

func _on_player_sight():
	pass

func _on_animation_finish():
	pass
	
func _on_death_timeout():
	pass
