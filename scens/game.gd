extends Node2D

var swipe_lengh = 40
var startPos: Vector2
var currPos: Vector2
var swiping = false
var speed = 100
var swiping_axis_thresh = 20

var swipe_start_time = 0
var swipe_end_time = 0

@onready var player = %Character/PlayerBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	

#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if Input.is_action_just_pressed("swipe - mause"):
		#if !swiping:
			#swiping = true
			#swipe_start_time = 0
			#swipe_end_time = 0
			#startPos = get_global_mouse_position()
	#if Input.is_action_pressed("swipe - mause"):		
		#if swiping:
			#swipe_end_time += delta
			#currPos = get_global_mouse_position()
			#var swipe_distance = currPos.distance_to(startPos)
			#if swipe_distance >= swipe_lengh:
				#var swipe_duration = (swipe_end_time - swipe_start_time)
				#var swipe_speed = swipe_distance * 2.5 / swipe_duration if swipe_duration > 0 else 0
				#if abs(startPos.y - currPos.y) <= swiping_axis_thresh:
					#var vec = Vector2.RIGHT if currPos.x > startPos.x  else Vector2.LEFT
					#swiping = false
					#player.move(vec, swipe_speed)
				#elif abs(startPos.x - currPos.x) <= swiping_axis_thresh:
					#var vec = Vector2.DOWN if currPos.y > startPos.y  else Vector2.UP
					#swiping = false
					#player.move(vec, swipe_speed)
	#else:
		#swiping = false
