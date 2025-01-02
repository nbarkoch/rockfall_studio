extends Node2D

@onready var animated_sprite = get_node("Area2D/AnimatedSprite2D")
@onready var roomManager = get_node("/root/RoomManager")

@export_enum(
	"DOWN_TO_LEFT",
	"DOWN_TO_RIGHT", 
	"RIGHT_TO_UP",
	"RIGHT_TO_DOWN", 
	"UP_TO_RIGHT", 
	"UP_TO_LEFT",
	"LEFT_TO_UP", 
	"LEFT_TO_DOWN")
var direction: String = "UP_TO_RIGHT"
var allowed_direction = [Vector2.UP, Vector2.RIGHT]

var tile_size = 104

func set_sprite_and_direction():
	var directions = {
		"DOWN_TO_LEFT": [Vector2.DOWN, Vector2.LEFT],
		"DOWN_TO_RIGHT" : [Vector2.DOWN, Vector2.RIGHT],
		"RIGHT_TO_UP": [Vector2.RIGHT, Vector2.UP], 
		"RIGHT_TO_DOWN":  [Vector2.RIGHT, Vector2.DOWN],
		"UP_TO_RIGHT" : [Vector2.UP, Vector2.RIGHT],
		"UP_TO_LEFT": [Vector2.UP, Vector2.LEFT],
		"LEFT_TO_UP": [Vector2.LEFT, Vector2.UP],
		"LEFT_TO_DOWN": [Vector2.LEFT, Vector2.DOWN],
	}
	var sprites = {
		"DOWN_TO_LEFT":  "downToLeft",
		"DOWN_TO_RIGHT" : "downToRight",
		"RIGHT_TO_UP": "rightToUp",
		"RIGHT_TO_DOWN":  "rightToDown",
		"UP_TO_RIGHT" : "upToRight",
		"UP_TO_LEFT": "upToLeft",
		"LEFT_TO_UP": "leftToUp",
		"LEFT_TO_DOWN": "leftToDown",
	}
	allowed_direction = directions[direction]
	animated_sprite.play(sprites[direction])
	animated_sprite.stop()

func _ready():
	set_sprite_and_direction()


func _on_area_2d_body_entered(body):
	if body is MovingBlock:
		var body_velocity = body.velocity if body.has_method("get_velocity") else Vector2.ZERO
		# Check if the body's velocity matches the allowed_direction[0]
		if -body_velocity.normalized() == allowed_direction[0]:
			# Change body's velocity to allowed_direction[1]
			if body.has_method("set_velocity"):
				body.set_velocity(allowed_direction[1] * body_velocity.length())
			body.set_position(position)
			body.locate()
			body.current_direction = allowed_direction[1]
			body.set_layer_direction(allowed_direction[1])
			# Optional: Update the sprite frame or play an animation
		animated_sprite.frame = 1
		
func _on_area_2d_body_exited(body):
	if body is MovingBlock:
		animated_sprite.frame = 0 
