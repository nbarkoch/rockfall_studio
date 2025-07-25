extends CanvasLayer

class_name DialogLayer

@onready var roomManager = get_node("/root/RoomManager")
@onready var nextButtonAnimation = $Control/Panel/ButtonsPanel/NextButton/AnimationPlayer
@onready var retryButtonAnimation = $Control/Panel/ButtonsPanel/RetryButton/AnimationPlayer
@onready var dialogLayerAnimation = $DialogAnimationPlayer

@onready var label = $Control/Panel/PanelContainer/Label
var content: String = ""

func _ready():
	label.text = content
	pass 

func enter():
	dialogLayerAnimation.play("enter")
	
func exit():
	dialogLayerAnimation.play("exit")
	
func _on_next_button_pressed():
	nextButtonAnimation.play("button_click")
	
func _on_retry_button_pressed():
	retryButtonAnimation.play("button_click")

func _on_next_animation_finished(anim_name):
	roomManager.to_next_level()

func _on_retry_animation_finished(anim_name):
	roomManager.retry_level()


func _on_dialog_finished(anim_name):
	if anim_name == "exit":
		roomManager.dialogAnimationExitFinished()
