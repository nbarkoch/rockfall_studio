extends Node2D


var swipe_lengh = 40
var startPos: Vector2
var currPos: Vector2
var swiping = false
var speed = 100
var swiping_axis_thresh = 20
var swipe_start_time = 0
var swipe_end_time = 0

var tileMap: TileMap = null

var currentLevelNum = 1

@onready var player: Player = null
signal player_position_changed(position: Vector2)

func _process(delta):
	if Input.is_action_just_pressed("swipe - mause"):
		if !swiping:
			swiping = true
			swipe_start_time = 0
			swipe_end_time = 0
			startPos = get_global_mouse_position()
	if Input.is_action_pressed("swipe - mause"):		
		if swiping:
			swipe_end_time += delta
			currPos = get_global_mouse_position()
			var swipe_distance = currPos.distance_to(startPos)
			if swipe_distance >= swipe_lengh:
				var swipe_duration = (swipe_end_time - swipe_start_time)
				var swipe_speed = swipe_distance * 2.5 / swipe_duration if swipe_duration > 0 else 0
				if abs(startPos.y - currPos.y) <= swiping_axis_thresh:
					var vec = Vector2.RIGHT if currPos.x > startPos.x  else Vector2.LEFT
					swiping = false
					player.move(vec, swipe_speed)
				elif abs(startPos.x - currPos.x) <= swiping_axis_thresh:
					var vec = Vector2.DOWN if currPos.y > startPos.y  else Vector2.UP
					swiping = false
					player.move(vec, swipe_speed)
	else:
		swiping = false

func setPlayer(player: Player):
	self.player = player
	setPlayerPosition(player.position)

func setTileMap(tileMap: TileMap):
	self.tileMap = tileMap

func get_player_position():
	if player != null:
		return player.position
	return Vector2.ZERO
	
	
func setPlayerPosition(position: Vector2):
	player.setPosition(position)
	emit_signal("player_position_changed", position)

var dialogLayer: DialogLayer = null

func finishLevel():
	get_tree().paused = true
	var dialog_layer_scene = load("res://scens/ui/dialog_layer.tscn")
	var dialog_layer: DialogLayer = dialog_layer_scene.instantiate()
	dialogLayer = dialog_layer
	add_child(dialog_layer)  
	dialog_layer.enter()


const levels = [
	"res://scens/levels/level1.tscn",
	"res://scens/levels/level2.tscn",
	"res://scens/levels/level3.tscn",
	"res://scens/levels/level4.tscn",
	"res://scens/levels/level5.tscn",
	"res://scens/levels/level6.tscn",
	"res://scens/levels/level7.tscn",
	"res://scens/levels/level8.tscn",
	"res://scens/levels/level9.tscn",
	"res://scens/levels/level10.tscn",
	"res://scens/levels/level11.tscn",
	"res://scens/levels/level12.tscn",
	"res://scens/levels/level13.tscn",
	"res://scens/levels/level14.tscn",
	"res://scens/levels/level15.tscn",
	"res://scens/levels/level16.tscn",
	"res://scens/levels/level17.tscn",
	"res://scens/levels/level18.tscn",
	"res://scens/levels/level19.tscn",
	"res://scens/levels/level20.tscn",
]

func loadLevel(level_num: int):
	currentLevelNum = level_num
	var tilemap_scene = load(levels[level_num - 1])
	var tilemap_instance: TileMap = tilemap_scene.instantiate()
	tilemap_instance.z_index = 0
	tilemap_instance.y_sort_enabled = true
	tilemap_instance.z_as_relative = true
	add_child(tilemap_instance)  
	setTileMap((tilemap_instance))
	
	var player_scene = load("res://scens/player_stuff/character.tscn")
	var player = player_scene.instantiate()
	player.z_index = 1
	player.y_sort_enabled = true
	player.z_as_relative = true
	tilemap_instance.add_child(player)
	player.position = Vector2.ZERO
	player.last_position = position
	setPlayer(player)


func toNextLevel():
	tileMap.queue_free()
	loadLevel(currentLevelNum + 1)
	
	
func retryLevel():
	tileMap.queue_free()
	loadLevel(currentLevelNum)
	
func dialogAnimationExitFinished():
	get_tree().paused = false
	dialogLayer.queue_free()
