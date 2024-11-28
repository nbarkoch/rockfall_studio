extends Statue

func _on_area_2d_body_entered(body):
	if body != self and body is Statue and\
			 collision_layer == body.collision_layer and\
			collision_mask == body.collision_mask:
		 # Calculate the opposite direction
		var player_position = body.position
		var opposite_direction = (position - player_position).normalized()
		move(opposite_direction, MIN_SPEED)
