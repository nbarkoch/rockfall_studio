extends Panel

@onready var nextButtonAnimation = $NextButton/AnimationPlayer
@onready var retryButtonAnimation = $RetryButton/AnimationPlayer

@onready var roomManager = get_node("/root/RoomManager")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_next_button_pressed():
	nextButtonAnimation.play("button_click")
	
func _on_retry_button_pressed():
	retryButtonAnimation.play("button_click")

func _on_next_animation_finished(anim_name):
	roomManager.toNextLevel()

func _on_retry_animation_finished(anim_name):
	roomManager.retryLevel()
