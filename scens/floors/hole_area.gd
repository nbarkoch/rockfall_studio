extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var block_handler = $BlockHandler
	
var capturedBody = null
var tempMapHanlder = null
func _on_body_entered(body):
	if inside_hole == null:
		var bodies = get_overlapping_bodies()
		if body is MovingBlock:
			var player_map = body.get_parent()
			if player_map is TileMap:	
				inside_hole = body
				tempMapHanlder = player_map
				tempMapHanlder.remove_child(body)
				block_handler.add_child(body)
				body.setPosition(Vector2.ZERO)
				body.move_from_p = Vector2.ZERO 
				body.disable_silding = true
				body.block()
				body.shadowSprite.visible = false
				capturedBody = body
				animation_player.play("fall")
		

		
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fall" and capturedBody and tempMapHanlder:
		block_handler.remove_child(capturedBody)
		tempMapHanlder.add_child(capturedBody)
		capturedBody.setPosition(position)
		capturedBody.disable_silding = false
		capturedBody.locate()
		capturedBody.z_index = -2
		capturedBody.sprite2D.position.y += 60
		# underground physics layer
		capturedBody.collision_layer = 2
		capturedBody.collision_mask = 2
		capturedBody.area2d.collision_layer = 2
		capturedBody.area2d.collision_mask = 2
		if capturedBody is Statue:
			capturedBody.z_index = -1
		


var inside_hole = null
