extends Node2D

class_name BlockOneSideEntryFloor

@onready var static_body = get_node("StaticBody2D")
@onready var collision_shape = get_node("StaticBody2D/CollisionShape2D")
@onready var animated_sprite = get_node("StaticBody2D/AnimatedSprite2D")
@onready var roomManager = get_node("/root/RoomManager")

@export_enum("UP", "DOWN", "LEFT", "RIGHT")
var direction: String = "UP"

var allowed_direction = Vector2.RIGHT
var tile_size = 104

const directions = {
	"UP": Vector2.UP,
	"DOWN": Vector2.DOWN,
	"LEFT": Vector2.LEFT,
	"RIGHT": Vector2.RIGHT,
}

const layers = {
	"UP": 30, #DOWN
	"DOWN": 29, #UP
	"LEFT": 32, #RIGHT
	"RIGHT": 31, #LEFT
}

func set_sprite():
	allowed_direction = directions[direction]
	animated_sprite.play(direction.to_lower())

func set_collision():
	static_body.collision_layer = 1 << layers[direction]
	
func _ready():
	set_sprite()
	set_collision()

