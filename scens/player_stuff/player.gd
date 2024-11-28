extends Statue

class_name Player

	
func block():
	current_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	position = last_position
	current_speed = 0
	roomManager.setPlayerPosition(position)
	audioStreamPlayer.stop()


