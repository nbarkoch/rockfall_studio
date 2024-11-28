extends Area2D

var hole_empty = true

@onready var animation_player = $AnimationPlayer
@onready var block_handler = $BlockHandler

var capturedCollision = null
func _on_body_entered(body):
	if hole_empty:
		var bodies = get_overlapping_bodies()
		if body is Player and not body.got_stuck:
			hole_empty = false
			var player = body.get_parent()
			var player_map = player.get_parent()
			if player_map is TileMap:			
				player_map.remove_child(player)
				body.position = Vector2.ZERO
				body.last_position = Vector2.ZERO
				# underground physics layer
				body.collision_layer = 2
				body.collision_mask = 2
				body.block()
				body.shadowSprite.visible = false
				capturedCollision = body.collisionShape
				block_handler.add_child(player)
				#body.got_stuck = true
				animation_player.play("fall")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fall" and capturedCollision:
		capturedCollision.position.y -= 40
