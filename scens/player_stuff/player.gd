extends CharacterBody2D

class_name Player

@onready var roomManager = get_node("/root/RoomManager")

@onready var audioStreamPlayer = $AudioStreamPlayer
@onready var shadowSprite = $ShadowSprite2D
@onready var statueSprite = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D

const MIN_SPEED = 1000
var current_speed = 0
var current_direction = Vector2.ZERO
var last_position : Vector2
var move_from_p : Vector2
var time_elapsed : float = 0.0
var tile_size = 104
var played_sound = false
var got_stuck = false

func _ready():
	last_position = position
	locate()	
	
	
# Function to set the direction and move the player
func move(direction: Vector2, speed: float):
	if current_speed == 0 and not got_stuck:
		time_elapsed = 0.0
		move_from_p = position
		last_position = position
		current_direction = direction
		current_speed = max(speed, MIN_SPEED)
		played_sound = false
		
	
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
			if 		collider is TileMap or\
					collider is StaticBody2D or\
					collider is CharacterBody2D:
				var collision_normal = collision.get_normal()
				if current_direction.dot(collision_normal) <= -0.95:
					block()
					break
			if collider is RigidBody2D:
				var collision_normal = collision.get_normal()
				if current_direction.dot(collision_normal) <= -0.95:
					current_speed = MIN_SPEED
					var success = push_rigidbody(collider, current_direction * current_speed)
					if not success:
						block()
						break
	
		velocity = current_direction * current_speed
		
		if not played_sound and (move_from_p - position).length() > 30:
			played_sound = true
			audioStreamPlayer.stream = preload("res://sounds/drag.ogg")
			audioStreamPlayer.play()
			
			
		move_and_slide()
	else:
		locate()		
	
	last_position.x = position.x
	last_position.y = position.y


var stuck_timer: float = 0.0
var stuck_memory_position = Vector2.ZERO
var stuck_timer_thresh = 0.01
func push_rigidbody(body: RigidBody2D, force: Vector2):
	var push_force = force * 0.1
	body.apply_central_impulse(push_force)
	if (body.linear_velocity.length() < 0.2 and stuck_timer >= stuck_timer_thresh) or body.sleeping:
		if abs(stuck_memory_position.x - last_position.x) < 1 \
		 and abs(stuck_memory_position.y - last_position.y) < 1:
			stuck_memory_position = last_position
			stuck_timer = 0.0
			return false
	if stuck_timer > stuck_timer_thresh:
		stuck_memory_position = last_position
		stuck_timer = 0.0
	stuck_timer += get_process_delta_time()
	return true

	
func block():
	current_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	position = last_position
	current_speed = 0
	roomManager.setPlayerPosition(position)
	audioStreamPlayer.stop()
	
func locate():
	var half_size = round( (tile_size/ 2))
	position.x = round((position.x) / half_size) * half_size
	position.y = round((position.y) / half_size) * half_size

