extends Area2D

var hole_empty = true

@onready var animation_player = $AnimationPlayer
@onready var block_handler = $BlockHandler

var capturedBody = null
func _on_body_entered(body):
	if hole_empty:
		var bodies = get_overlapping_bodies()
		if body.is_in_group("Blocks"):
			hole_empty = false
			var player_map = body.get_parent()
			if player_map is TileMap:	
				player_map.remove_child(body)
				body.position = Vector2.ZERO
				body.last_position = Vector2.ZERO
				body.block()
				body.shadowSprite.visible = false
				capturedBody = body
				block_handler.add_child(body)
				#body.got_stuck = true
				animation_player.play("fall")


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fall" and capturedBody:
		capturedBody.collisionShape.position.y -= 60
		# underground physics layer
		capturedBody.collision_layer = 2
		capturedBody.collision_mask = 2
