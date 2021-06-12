extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var collider = $Collider

func disable():
	print("called disable")
	collider.set_disabled(true)

func enable():
	print("called enable")
	collider.set_disabled(false)

func set_in_npc_layer():
	set_collision_layer_bit(18, true)
	set_collision_layer_bit(19, false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
