extends Node2D

@onready var roomManager = get_node("/root/RoomManager")
@onready var tileMap = get_node("TileMap")  
@onready var retryAnimationPlayer = $CanvasLayer/RetryButton/AnimationPlayer
@onready var homeAnimationPlayer = $CanvasLayer/HomeButton/AnimationPlayer


@onready var title_panel_container = $CanvasLayer/TitlePanelContainer
@onready var title = $CanvasLayer/TitlePanelContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	roomManager.connect("on_level_changed", on_level_changed)
	roomManager.load_level(20)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_retry_button_pressed():
	retryAnimationPlayer.play("button_click")


func _on_retry_animation_finished(anim_name):
	roomManager.retry_level()

func set_title(text: String):
	title.text = text
	title_panel_container.visible = not text.is_empty()
	
func on_level_changed(level_num: int):
	set_title("LEVEL " + str(level_num))


func _on_home_button_pressed():
	homeAnimationPlayer.play("button_click")


func _on_home_animation_finished(anim_name):
	pass # Replace with function body.
