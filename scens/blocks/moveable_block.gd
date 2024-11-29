extends RigidBody2D

var tile_size = 104

@onready var shadowSprite = $ShadowSprite2D
@onready var sprite2D = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	gravity_scale = 0

var stuck_timer: float = 0.0
var stuck_memory_position = Vector2.ZERO
var stuck_timer_thresh = 0.3
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_moving():
		locate()
		
func is_moving():
	if linear_velocity.length() < 100 or sleeping:
		if abs(stuck_memory_position.x - position.x) < 1 \
		 and abs(stuck_memory_position.y - position.y) < 1:
			stuck_memory_position = position
			stuck_timer = 0.0
			return false
	if stuck_timer > stuck_timer_thresh:
		stuck_memory_position = position
		stuck_timer = 0.0
	stuck_timer += get_process_delta_time()
	return true

func setPosition(newPosition: Vector2):
	position = newPosition
	
func locate():
	linear_velocity = linear_velocity / 2
	var half_size = round( (tile_size/ 2))
	position.x = round((position.x) / half_size) * half_size
	position.y = round((position.y) / half_size) * half_size
