extends Node2D

@onready var roomManager = get_node("/root/RoomManager")
	
func _ready():
	# Assuming the starting tile is at grid position (start_x, start_y)
	var start_x = 2  # Example X coordinate of start tile (in grid space)
	var start_y = 1  # Example Y coordinate of start tile (in grid space)
	# Tile size is known to be 104
	var tile_size = 104
	# Calculate the world position based on grid coordinates and tile size
	var start_position = Vector2(start_x * tile_size  , start_y * tile_size)
	
	# Now set the player's position to this calculated start position
	roomManager.setPlayerPosition(start_position)

