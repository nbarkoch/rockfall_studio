extends CharacterBody2D

class_name MovingBlock

@onready var roomManager = get_node("/root/RoomManager")

@onready var audioStreamPlayer = $AudioStreamPlayer
@onready var shadowSprite = $ShadowSprite2D
@onready var sprite2D = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D

@onready var area2d = $Area2D
@onready var area2dCollisionShape = $Area2D/CollisionShape2D

const MIN_SPEED = 1000
const MAX_SPEED = 10000
var current_speed = 0
var current_direction = Vector2.ZERO
var move_from_p : Vector2
var time_elapsed : float = 0.0
var tile_size = 104
var played_sound = false

var disable_silding = false

var pure_collision_mask: int 
const layers = {
	Vector2.UP: 29, 
	Vector2.DOWN: 30,
	Vector2.LEFT: 31,
	Vector2.RIGHT: 32,
}

func _ready():
	move_from_p = position
	locate()
	pure_collision_mask = collision_mask

	
func set_layer_direction(direction: Vector2):
	collision_mask = pure_collision_mask
	collision_mask |= 1 << layers[direction]
	
	
func redirect(direction: Vector2):
	move_from_p = position
	current_direction = direction
	set_layer_direction(direction)
	
# Function to set the direction and move the block
func move(direction: Vector2, speed: float):
	if current_speed == 0:
		time_elapsed = 0.0
		move_from_p = position
		current_direction = direction
		current_speed = min(max(speed, MIN_SPEED), MAX_SPEED)
		played_sound = false
		set_layer_direction(direction)
		
	
var fog_effect: PackedScene = preload("res://scens/effects/small_fog.tscn")	
var fog_instance: Node2D = null
func create_fog_effect():
	fog_instance = fog_effect.instantiate()
	fog_instance.position = current_direction * (tile_size / -3)
	if current_direction == Vector2.LEFT:
		fog_instance.flipped = true
	add_child(fog_instance)
	
func remove_fog_effect():
	if fog_instance != null:
		fog_instance.request_remove()
	
func _physics_process(delta):
	if abs(current_direction.x) > 0:
		position.y = move_from_p.y
	elif abs(current_direction.y) > 0:
		position.x = move_from_p.x
		
	if current_speed != 0:
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			var collision_normal = collision.get_normal()
			
			if current_direction.dot(collision_normal) <= -0.95:
				if collider is TileMap or collider is StaticBody2D:
					block()
					break
				elif self is Statue\
					 and collider is Statue\
					 and collider.current_speed == 0:
					# Trigger movement on the collided statue before blocking
					var push_direction = -collision_normal
					if is_movable(current_direction):
						if not played_sound:
							on_moved()
						collider.move(push_direction, MIN_SPEED * 2)
					block()
					break
				elif collider is MovingBlock:
					if not is_movable(current_direction):
						block()
						break
		
		velocity = current_direction * current_speed
		
		if not played_sound and (move_from_p - position).length() > 30:
			played_sound = true
			audioStreamPlayer.stream = preload("res://sounds/drag.ogg")
			audioStreamPlayer.play()
			on_moved()
		
		move_and_slide()
		
	elif move_from_p != position:
		move_and_slide()
		locate()
	elif not disable_silding:
		velocity = Vector2.ZERO
		collision_mask = pure_collision_mask
		move_and_slide()
		#audioStreamPlayer.stop()
		
		
func is_movable(direction: Vector2, checked_bodies: Array = []) -> bool:
	# Prevent infinite recursion by tracking checked bodies
	if self in checked_bodies:
		return false
	checked_bodies.append(self)
	
	collision_mask |= 1 << layers[direction]
	# Cast a ray in the movement direction to check for potential collisions
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		position,
		position + direction * tile_size,
		collision_mask,
		[self]  # Exclude self from collision check
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		
		# Check for BlockOneSideEntryFloor
		if collider is BlockOneSideEntryFloor:
			if collider.allowed_direction == -direction:
				return false
		
		# If this is a MovingBlock and it encounters a Statue, treat it as immovable
		if self is MovingBlock and\
			 not self is Statue and\
				 collider is Statue:
			return false
			
		# For other cases (Statue pushing Statue, or MovingBlock encountering MovingBlock)
		if collider is MovingBlock or collider is Statue:
			# If the collider has current_speed > 0, it's already moving and can continue
			if collider.current_speed > 0:
				return true
			# Otherwise check if it can be moved
			return collider.is_movable(direction, checked_bodies)
			
		# Any other type of collider blocks movement
		return false
	
	# No collision found, movement is possible
	return true
	
	
func block():
	current_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	current_speed = 0
	collision_mask = pure_collision_mask
	audioStreamPlayer.stop()
	remove_fog_effect()
	
	
func on_moved():
	create_fog_effect()
	
func locate():
	var half_size = round( (tile_size/ 2))
	var pX = 1 if position.x >= 0 else 0
	var pY = 1 if position.y >= 0 else 0
	var grid_pos = Vector2(round((position.x) / half_size) * half_size,
						   round((position.y) / half_size) * half_size)
	grid_pos.x = (round((grid_pos.x) / tile_size) - pX) * tile_size + half_size
	grid_pos.y = (round((grid_pos.y) / tile_size) - pY) * tile_size + half_size
	move_from_p = grid_pos
	position = grid_pos
	pusher = null
	audioStreamPlayer.stop()

func is_positioned_in_grid(position: Vector2) -> bool:
	return abs(int(position.x) % tile_size) == tile_size / 2 and abs(int(position.y) % tile_size) == tile_size / 2
	
var pusher = null

func _on_area_2d_body_entered(body):
	if current_speed == 0 \
	and body != self \
	and body is MovingBlock \
	and collision_layer == body.collision_layer \
	and pure_collision_mask == body.pure_collision_mask:
		if pusher != body and body.current_speed != 0:
			var collision_normal = (position - body.position).normalized()
			var normalized_body_direction = body.current_direction.normalized()
			
			# First check if moving blocks are aligned properly
			var is_aligned = false
			var direction_check = false
			
			if abs(normalized_body_direction.x) > 0.9:  # Horizontal movement
				is_aligned = abs(position.y - body.position.y) < 5  # Small threshold for floating point imprecision
				# Check if the block is being pushed from the correct side
				direction_check = sign(position.x - body.position.x) == sign(normalized_body_direction.x)
			else:  # Vertical movement
				is_aligned = abs(position.x - body.position.x) < 5  # Small threshold for floating point imprecision
				# Check if the block is being pushed from the correct side
				direction_check = sign(position.y - body.position.y) == sign(normalized_body_direction.y)
			
			# If aligned and being pushed from correct direction
			if is_aligned and direction_check and is_movable(normalized_body_direction):
				pusher = body
				move(normalized_body_direction, body.current_speed)
				
				
func _on_area_2d_body_exited(body):
	pusher = null
