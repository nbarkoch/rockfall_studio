extends Area2D

var hole_empty = true

@onready var animation_player = $AnimationPlayer
@onready var block_handler = $BlockHandler

var capturedBody = null
var tempMapHanlder = null
func _on_body_entered(body):
	if hole_empty:
		var bodies = get_overlapping_bodies()
		if body.is_in_group("Blocks"):
			hole_empty = false
			var player_map = body.get_parent()
			if player_map is TileMap:	
				tempMapHanlder = player_map
				tempMapHanlder.remove_child(body)
				block_handler.add_child(body)
				if body is Statue:
					body.setPosition(Vector2.ZERO)
					body.block()
				body.shadowSprite.visible = false
				capturedBody = body
				animation_player.play("fall")
		

		
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fall" and capturedBody and tempMapHanlder:
		block_handler.remove_child(capturedBody)
		tempMapHanlder.add_child(capturedBody)
		capturedBody.setPosition(position)
		capturedBody.z_index = -2
		capturedBody.sprite2D.position.y += 60
		# underground physics layer
		capturedBody.collision_layer = 2
		capturedBody.collision_mask = 2
		if capturedBody is Statue:
			capturedBody.z_index = -1
			capturedBody.area2d.collision_layer = 2
			capturedBody.area2d.collision_mask = 2
			
