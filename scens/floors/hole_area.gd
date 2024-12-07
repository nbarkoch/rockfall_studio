extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var block_handler = $BlockHandler
@onready var hole_area_2d = $HoleArea2D

var inside_hole = null
var capturedBody = null
var tempMapHanlder = null

func _physics_process(_delta):
	var found_underground_block = false
	
	for body in hole_area_2d.get_overlapping_bodies():
		if body is MovingBlock and body.collision_layer == 2:
			found_underground_block = true
			if inside_hole != body:
				inside_hole = body
			break
	
	if !found_underground_block and inside_hole != null and capturedBody == null:
		inside_hole = null
		try_capture_block()

func try_capture_block():
	if inside_hole != null:
		return
		
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is MovingBlock:
			var player_map = body.get_parent()
			if player_map is TileMap:    
				start_fall_sequence(body, player_map)
				break

func start_fall_sequence(body, player_map):
	inside_hole = body
	tempMapHanlder = player_map
	tempMapHanlder.remove_child(body)
	block_handler.add_child(body)
	body.set_position(Vector2.ZERO)
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
		capturedBody.set_position(position)
		capturedBody.disable_silding = false
		capturedBody.locate()
		capturedBody.z_index = -2
		capturedBody.sprite2D.position.y += 45
		capturedBody.collision_layer = 2
		capturedBody.collision_mask = 2
		capturedBody.area2d.collision_layer = 2
		capturedBody.area2d.collision_mask = 2
		if capturedBody is MovingStatue:
			capturedBody.sprite2D.position.y += 20
		if capturedBody is Statue:
			capturedBody.z_index = -1
	capturedBody = null
	tempMapHanlder = null

func _on_body_entered(body):
	try_capture_block()
