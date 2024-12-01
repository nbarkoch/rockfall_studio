extends Statue

class_name Player

	
func block():
	super.block()
	roomManager.setPlayerPosition(position)


