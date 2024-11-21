extends Node2D

@onready var roomManager = get_node("/root/RoomManager")
@onready var tileMap = get_node("TileMap")  

# Called when the node enters the scene tree for the first time.
func _ready():
	if tileMap:
		roomManager.setTileMap(tileMap)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
