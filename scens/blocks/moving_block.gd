extends CharacterBody2D

class_name MovingBlock

# Constants
const MIN_SPEED = 1000
const MAX_SPEED = 10000
const TILE_SIZE = 104
const HALF_TILE_SIZE = TILE_SIZE / 2
const DIRECTION_LAYERS = {
	Vector2.UP: 28, 
	Vector2.DOWN: 29,
	Vector2.LEFT: 30,
	Vector2.RIGHT: 31,
}

# Onready variables
@onready var roomManager = get_node("/root/RoomManager")
@onready var audioStreamPlayer = $AudioStreamPlayer
@onready var shadowSprite = $ShadowSprite2D
@onready var sprite2D = $AnimatedSprite2D
@onready var collisionShape = $CollisionShape2D
@onready var area2d = $Area2D
@onready var area2dCollisionShape = $Area2D/CollisionShape2D

# Movement variables
var current_speed = 0
var current_direction = Vector2.ZERO
var move_from_p: Vector2
var played_sound = false
var disable_silding = false
var pure_collision_mask: int
var pusher = null
var fog_instance: Node2D = null

# Preloads
var fog_effect = preload("res://scens/effects/small_fog.tscn")

func _ready():
	move_from_p = position
	locate()
	pure_collision_mask = collision_mask
	_setup_physics()

func _setup_physics():
	slide_on_ceiling = false
	floor_stop_on_slope = true
	floor_block_on_wall = true
	platform_floor_layers = 1
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

func set_layer_direction(direction: Vector2):
	collision_mask = pure_collision_mask
	collision_mask |= 1 << DIRECTION_LAYERS[direction]

func redirect(direction: Vector2):
	move_from_p = position
	current_direction = direction
	set_layer_direction(direction)

func move(direction: Vector2, speed: float):
	if current_speed == 0 and is_movable(direction):
		move_from_p = position
		current_direction = direction
		current_speed = clamp(speed, MIN_SPEED, MAX_SPEED)
		played_sound = false
		set_layer_direction(direction)

func create_fog_effect():
	remove_fog_effect() 
	fog_instance = fog_effect.instantiate()
	fog_instance.position = current_direction * (TILE_SIZE / -3)
	if current_direction == Vector2.LEFT:
		fog_instance.flipped = true
	add_child(fog_instance)

func remove_fog_effect():
	if fog_instance != null:
		fog_instance.request_remove()

func _physics_process(_delta):
	_maintain_axis_alignment()
	
	if pusher != null and pusher.current_direction != current_direction:
		pusher = null
	
	if current_speed != 0:
		_handle_collisions()
		_update_movement()
	elif move_from_p != position:
		_reset_position()
	elif not disable_silding:
		_handle_idle()

func _maintain_axis_alignment():
	if abs(current_direction.x) > 0:
		position.y = move_from_p.y
	elif abs(current_direction.y) > 0:
		position.x = move_from_p.x

func _handle_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var collision_normal = collision.get_normal()
		
		if current_direction.dot(collision_normal) <= -0.95:
			if _should_block_on_collision(collider, collision_normal):
				block()
				break

func _should_block_on_collision(collider, collision_normal):
	if collider is TileMap or collider is StaticBody2D:
		return true
	elif self is Statue and collider is Statue and collider.current_speed == 0:
		_handle_statue_collision(collider, collision_normal)
		return true
	elif collider is MovingBlock:
		return not is_movable(current_direction)
	return false

func _handle_statue_collision(collider, collision_normal):
	var push_direction = -collision_normal
	if is_movable(current_direction):
		if not played_sound:
			on_moved()
		collider.move(push_direction, MIN_SPEED * 2)

func _update_movement():
	velocity = current_direction * current_speed
	
	var distance = (move_from_p - position).length()
	if not played_sound and distance > HALF_TILE_SIZE:
		_play_movement_sound()
		on_moved()
	
	move_and_slide()

func _play_movement_sound():
	played_sound = true
	audioStreamPlayer.stream = preload("res://sounds/drag.ogg")
	audioStreamPlayer.play()

func _reset_position():
	velocity = Vector2.ZERO
	locate()
	move_and_slide()

func _handle_idle():
	velocity = Vector2.ZERO
	collision_mask = pure_collision_mask
	move_and_slide()

func is_movable(direction: Vector2, checked_bodies: Array = []) -> bool:
	if self in checked_bodies:
		return false
		
	checked_bodies.append(self)
	collision_mask |= 1 << DIRECTION_LAYERS[direction]
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsRayQueryParameters2D.create(
		position,
		position + direction * TILE_SIZE,
		collision_mask,
		[self]
	)
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result.collider
		
		if collider is BlockOneSideEntryFloor and collider.allowed_direction == -direction:
			return false
			
		if self is MovingBlock and not self is Statue and collider is Statue:
			return false
			
		if collider is MovingBlock or collider is Statue:
			if collider.current_speed > 0:
				return true
			return collider.is_movable(direction, checked_bodies)
			
		return false
	
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
	var grid_x = round((position.x - HALF_TILE_SIZE) / TILE_SIZE) * TILE_SIZE + HALF_TILE_SIZE
	var grid_y = round((position.y - HALF_TILE_SIZE) / TILE_SIZE) * TILE_SIZE + HALF_TILE_SIZE
	move_from_p = Vector2(grid_x, grid_y)
	position = move_from_p
	pusher = null
	audioStreamPlayer.stop()
	

func _on_area_2d_body_entered(body):
	if _can_be_pushed_by(body):
		_handle_potential_push(body)

func _can_be_pushed_by(body) -> bool:
	return current_speed == 0 \
		and body != self \
		and body is MovingBlock \
		and collision_layer == body.collision_layer \
		and pure_collision_mask == body.pure_collision_mask

func _handle_potential_push(body):
	if pusher != body and body.current_speed != 0:
		var collision_normal = (position - body.position).normalized()
		var body_direction = body.current_direction.normalized()
		
		if _is_aligned_with_pusher(body, body_direction) and\
		   _is_push_direction_valid(body_direction, collision_normal) and\
			is_movable(body_direction):
				pusher = body
				move(body_direction, body.current_speed)

func _is_aligned_with_pusher(body, body_direction) -> bool:
	if abs(body_direction.x) > 0.9:
		return abs(position.y - body.position.y) < 5
	return abs(position.x - body.position.x) < 5

func _is_push_direction_valid(body_direction: Vector2, collision_normal: Vector2) -> bool:
	return body_direction.dot(collision_normal) >= 0.99

func _on_area_2d_body_exited(_body):
	pusher = null
