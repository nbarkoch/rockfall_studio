extends CharacterBody2D

class_name Player

const MIN_SPEED = 1000
var current_speed = 0
var current_direction = Vector2.ZERO
var previous_position : Vector2
var time_elapsed : float = 0.0
var stop_time : float = 0.05 

func _ready():
	previous_position = position
	time_elapsed = 0.0
	
# Function to set the direction and move the player
func move(direction: Vector2, speed: float):
	if current_speed == 0:
		time_elapsed = 0.0
		current_direction = direction
		current_speed = max(speed, MIN_SPEED)
	

func _physics_process(delta):
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() is TileMap:
			time_elapsed += delta
		else:
			time_elapsed = 0.0
		
		if time_elapsed >= stop_time:
			if abs(position.x - previous_position.x) < 0.01 and \
					abs(position.y - previous_position.y) < 0.01:
				current_speed = 0
				current_direction = Vector2.ZERO
				
			time_elapsed = 0.0
			previous_position = position
			
	velocity = current_direction * current_speed
	move_and_slide()
