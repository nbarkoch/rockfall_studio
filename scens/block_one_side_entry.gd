extends Node2D

@onready var collision_shape = get_node("StaticBody2D/CollisionShape2D")
@onready var animated_sprite = get_node("StaticBody2D/AnimatedSprite2D")
@onready var gameManager = get_node("/root/GameManager")

@export_enum("UP", "DOWN", "LEFT", "RIGHT")
var direction: String = "UP"

var allowed_direction = Vector2.RIGHT
var should_disable_collision = false
var tile_size = 104

func set_sprite():
	var directions = {
		"UP": Vector2.UP,
		"DOWN": Vector2.DOWN,
		"LEFT": Vector2.LEFT,
		"RIGHT": Vector2.RIGHT,
	}
	allowed_direction = directions[direction]
	animated_sprite.play(direction.to_lower())

func _ready():
	set_sprite()
	gameManager.connect("player_position_changed", on_player_position_changed)
	on_player_position_changed(gameManager.get_player_position())
	

func _process(delta):
	collision_shape.disabled = should_disable_collision


func on_player_position_changed(player_position: Vector2):
	
	var block_position = position
	var player_about_to_do = Vector2.ZERO
	if abs(block_position.y - player_position.y) < tile_size:
		player_about_to_do = Vector2.RIGHT if block_position.x - player_position.x else Vector2.LEFT
	if abs(block_position.x - player_position.x) < tile_size:
		player_about_to_do = Vector2.DOWN if block_position.y - player_position.y else Vector2.UP
	# Enable or disable collision based on the direction
	should_disable_collision = (player_about_to_do == allowed_direction)
