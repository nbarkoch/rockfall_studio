extends CharacterBody2D

class_name Player

@onready var gameManager = get_node("/root/GameManager")



const MIN_SPEED = 1000
var current_speed = 0
var current_direction = Vector2.ZERO
var last_position : Vector2
var time_elapsed : float = 0.0
var stop_time : float = 0.05 
var tile_size = 104

func _ready():
	last_position = position
	position.x = round(position.x / tile_size) * tile_size - 3
	position.y = round(position.y / tile_size) * tile_size +  7
	gameManager.setPlayer(self)
	
	
# Function to set the direction and move the player
func move(direction: Vector2, speed: float):
	if current_speed == 0:
		time_elapsed = 0.0
		last_position = position
		current_direction = direction
		current_speed = max(speed, MIN_SPEED)
	
func _physics_process(delta):
	if abs(current_direction.x) > 0:
		position.y = last_position.y
	elif abs(current_direction.y) > 0:
		position.x = last_position.x
	if current_speed == 0:
		position.x = last_position.x
		position.y = last_position.y
	
	
	if current_speed != 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			if collider is TileMap or collider is StaticBody2D:
				var collision_normal = collision.get_normal()
				if current_direction.dot(collision_normal) <= -0.95:
					block()
					break
	
		velocity = current_direction * current_speed
		move_and_slide()
	else:
		position.x = round(position.x / tile_size) * tile_size - 3
		position.y = round(position.y / tile_size) * tile_size +  7
	
	last_position.x = position.x
	last_position.y = position.y


func block():
	current_direction = Vector2.ZERO
	position = last_position
	current_speed = 0
	gameManager.setPlayerPosition(position)
