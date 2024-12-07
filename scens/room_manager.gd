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

var current_level_num = 1
var current_num_steps = 0

@onready var player: Player = null
signal player_position_changed(position: Vector2)
signal on_level_changed(level_num: int)

func _ready():
	load_levles_config()

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

func set_player(player: Player):
	self.player = player
	set_player_position(player.position)

func set_tileMap(tileMap: TileMap):
	self.tileMap = tileMap

func get_player_position():
	if player != null:
		return player.position
	return Vector2.ZERO
	
func add_step():
	current_num_steps += 1
	
func set_player_position(position: Vector2):
	player.set_position(position)
	emit_signal("player_position_changed", position)

var dialog_layer: DialogLayer = null
const MAX_SCORE = 10
func finish_level():
	var min_steps = levels_data[current_level_num - 1]["minSteps"]
	var max_steps = min_steps * 4
	
	var score = int(MAX_SCORE - (((current_num_steps - min_steps) * MAX_SCORE)/(max_steps - min_steps)))
	get_tree().paused = true
	var dialog_layer_scene = load("res://scens/ui/dialog_layer.tscn")
	dialog_layer = dialog_layer_scene.instantiate()
	var title = ""
	if score >= 1 and score <= 3:
		title = "Could Done Better!"
	elif score >= 4 and score <= 7:
		title = "Good Job!"
	elif score >= 8 and score <= 10:
		title = "Congrats!"
	# Set the dialog content
	dialog_layer.content = """
	%s
	Score: %d
	Steps: %d
	""" % [title, score, current_num_steps]
	add_child(dialog_layer)  
	dialog_layer.enter()


func get_level_path(level_num: int) -> String:
	return "res://scens/levels/level%d.tscn" % level_num

func load_level(level_num: int):
	current_level_num = level_num
	current_num_steps = 0
	var level_path = get_level_path(current_level_num)
	var tilemap_scene = load(level_path)
	var tilemap_instance: TileMap = tilemap_scene.instantiate()
	tilemap_instance.z_index = 0
	tilemap_instance.y_sort_enabled = true
	tilemap_instance.z_as_relative = true
	add_child(tilemap_instance)  
	set_tileMap((tilemap_instance))
	
	var player_scene = load("res://scens/player_stuff/character.tscn")
	var player = player_scene.instantiate()
	player.z_index = 1
	player.y_sort_enabled = true
	player.z_as_relative = true
	tilemap_instance.add_child(player)
	player.set_position(Vector2.ZERO)
	set_player(player)
	emit_signal("on_level_changed", level_num)


func to_next_level():
	tileMap.queue_free()
	load_level(current_level_num + 1)
	if dialog_layer != null:
		dialog_layer.exit()
	
	
func retry_level():
	tileMap.queue_free()
	load_level(current_level_num)
	if dialog_layer != null:
		dialog_layer.exit()
	
func dialogAnimationExitFinished():
	get_tree().paused = false
	dialog_layer.queue_free()

var levels_data = null
func load_levles_config():
	var file = "res://scens/levels/levels.json"
	var json_as_text = FileAccess.get_file_as_string(file)
	var json_as_dict = JSON.parse_string(json_as_text)
	if json_as_dict:
		levels_data = json_as_dict
