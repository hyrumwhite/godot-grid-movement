extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var input_direction = Vector2.ZERO
var previous_input_direction = Vector2.ZERO

var walk_speed = 75
enum PlayerStates {
	WALKING,
	STOPPING,
	IDLE
}
var player_state = PlayerStates.IDLE
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	process_input()
	move_and_collide(input_direction * delta * walk_speed)
	if player_state == PlayerStates.WALKING:
		walk(delta)
	elif player_state == PlayerStates.STOPPING:
		stop(delta)
	elif player_state == PlayerStates.IDLE:
		idle()
		
func process_input():
	if input_direction != Vector2.ZERO:
		previous_input_direction = input_direction
	if input_direction.y == 0:
		input_direction.x = int(Input.get_action_strength("ui_right")) - int(Input.get_action_strength("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.get_action_strength("ui_down")) - int(Input.get_action_strength("ui_up"))
		
	if input_direction != Vector2.ZERO:
		player_state = PlayerStates.WALKING
	elif player_state == PlayerStates.WALKING:
		add_stopper()
		player_state = PlayerStates.STOPPING

func walk(delta):
	var result = move_and_collide(input_direction * walk_speed * delta)
	
func stop(delta):
	var result = move_and_collide(previous_input_direction * walk_speed * delta)	
	if result:
		#result.collider.queue_free();
		player_state = PlayerStates.IDLE

func idle():
	pass
	
func add_stopper():
	var stopperClass = load("res://MovementStopper.tscn")
	var stopper = stopperClass.instance()
	var x_remainder = fmod(position.x, 16)
	var y_remainder = fmod(position.y, 16)
	if x_remainder != 0:
		stopper.position.x = position.x - x_remainder + 16
	if y_remainder != 0:
		stopper.position.y = position.y - y_remainder - 16
	get_parent().add_child(stopper)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
