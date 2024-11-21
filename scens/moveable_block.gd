extends RigidBody2D

var tile_size = 104
# Called when the node enters the scene tree for the first time.
func _ready():
	gravity_scale = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if linear_velocity.length() < 400 or sleeping:
		locate()
		

func locate():
	var half_size = round( (tile_size/ 2))
	position.x = round((position.x) / half_size) * half_size
	position.y = round((position.y) / half_size) * half_size
