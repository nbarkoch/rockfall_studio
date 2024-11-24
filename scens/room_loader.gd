extends Node2D

@onready var roomManager = get_node("/root/RoomManager")
@onready var tileMap = get_node("TileMap")  
@onready var retryAnimationPlayer = $CanvasLayer/RetryButton/AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	roomManager.loadLevel(8)
	#if tileMap:
		#roomManager.setTileMap(tileMap)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_retry_button_pressed():
	retryAnimationPlayer.play("button_click")


func _on_retry_animation_finished(anim_name):
	roomManager.retryLevel()
