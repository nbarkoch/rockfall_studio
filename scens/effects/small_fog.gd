extends Node2D
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var animated_sprite_2d_2 = $AnimatedSprite2D2

var should_remove = false
var flipped = false
# Called when the node enters the scene tree for the first time.
func _ready():
	animated_sprite_2d.play("default")
	animated_sprite_2d_2.play("default")
	animated_sprite_2d.flip_h = flipped
	animated_sprite_2d_2.flip_h = flipped

func request_remove():
	should_remove = true

var animation1_done = false
func _on_animated_sprite_2d_animation_looped():
	if should_remove:
		if animation2_done:
			queue_free()
			return
		animation1_done = true
		animated_sprite_2d.queue_free()

var animation2_done = false
func _on_animated_sprite_2d_2_animation_looped():
	if should_remove:
		if animation1_done:
			queue_free()
			return
		animation2_done = true
		animated_sprite_2d_2.queue_free()
