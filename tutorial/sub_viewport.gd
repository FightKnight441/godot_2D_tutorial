extends SubViewport

@export var camera_node : Node2D
@export var player_node : Node2D

func _ready() -> void:
	# "world_2d" refers to this SubViewport's own 2D world.
	# "get_tree().root" will fetch the game's main viewport.
	world_2d = get_tree().root.world_2d

# Reference the camera and the player
# "@export" keyword will expose these two variables in the inspector

func _process(delta: float) -> void:
	# Let camera move with player
	camera_node.position = player_node.position
