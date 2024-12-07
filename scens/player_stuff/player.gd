extends Statue

class_name Player

	
func block():
	super.block()
	roomManager.set_player_position(position)


func on_moved():
	super.on_moved()
	roomManager.add_step()
