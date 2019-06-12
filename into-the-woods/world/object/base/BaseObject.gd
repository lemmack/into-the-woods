extends RigidBody2D
# class_name may cause circular references in some cases :/
class_name BaseObject

# set to the player when in inventory and null when not
var player = null

func _ready():
	pass

# hold item
func equip():
	pass

# perform primary action
func primary():
	pass

# perform secondary action
func secondary():
	pass

# unhold item
func unequip():
	pass
