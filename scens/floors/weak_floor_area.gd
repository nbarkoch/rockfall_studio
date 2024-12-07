extends Area2D

var body_in_hole = false
var hole_empty = true
var check_timer: Timer
@onready var animation_player = $AnimationPlayer
@onready var block_handler = $BlockHandler
func _ready():
	# Create and configure timer
	check_timer = Timer.new()
	check_timer.wait_time = 0.1  # Check every 0.1 seconds
	check_timer.one_shot = false
	add_child(check_timer)
	check_timer.timeout.connect(_on_check_timer_timeout)

func _on_body_entered(body):
	if body is Player:
		body_in_hole = true
		check_timer.start()

func _on_body_exited(body):
	if body is Player:
		body_in_hole = false
		check_timer.stop()

func _on_check_timer_timeout():
	if body_in_hole and hole_empty:
		var bodies = get_overlapping_bodies()
		for body in bodies:
			if body is Player and body.current_speed == 0 and not body.got_stuck:
				var original_parent = body.get_parent()
				original_parent.remove_child(body)
				body.set_position(Vector2.ZERO)
				body.shadowSprite.z_index = -2
				block_handler.add_child(body)
				body.got_stuck = true
				animation_player.play("fall")
				check_timer.stop()  # Stop checking once we've detected the fall
				# Add your falling logic here
				hole_empty = false
				break
