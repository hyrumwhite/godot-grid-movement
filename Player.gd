extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var input_direction = Vector2.ZERO
var previous_input_direction = Vector2.ZERO
var stopper = null
var stopperClass = null;
var walk_speed = 55
var tile_size = 16
enum PlayerStates {
	WALKING,
	STOPPING,
	IDLE
}
var player_state = PlayerStates.IDLE
# Called when the node enters the scene tree for the first time.
func _ready():
	stopperClass = load("res://MovementStopper.tscn")

	
func _physics_process(delta):
	process_input()
	if player_state == PlayerStates.WALKING:
		walk(delta)
	elif player_state == PlayerStates.STOPPING:
		stop(delta)
	elif player_state == PlayerStates.IDLE:
		idle()
		
func process_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.get_action_strength("ui_right")) - int(Input.get_action_strength("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.get_action_strength("ui_down")) - int(Input.get_action_strength("ui_up"))
		
	if input_direction != Vector2.ZERO and player_state != PlayerStates.STOPPING:
		previous_input_direction = input_direction
		player_state = PlayerStates.WALKING
	elif player_state == PlayerStates.WALKING:
		#player has released the walking action
		add_stopper()
		player_state = PlayerStates.STOPPING

func walk(delta):
	var result = move_and_collide(input_direction * walk_speed * delta)
		
func stop(delta):
	var result = move_and_collide(previous_input_direction * walk_speed * delta)	
	if result:
		stopper.queue_free();
		player_state = PlayerStates.IDLE

func idle():
	pass
	
func add_stopper():
	if is_instance_valid(stopper):
		stopper.queue_free()
	stopper = stopperClass.instance()
	stopper.position.x = position.x
	stopper.position.y = position.y
	if(previous_input_direction.x > 0):#moving right
		var right_edge = position.x + tile_size
		var x_remainder = fmod(right_edge, tile_size)
		stopper.position.x = right_edge - x_remainder + tile_size
	elif(previous_input_direction.x < 0):#moving left
		var x_remainder = fmod(position.x, tile_size)
		stopper.position.x = position.x - x_remainder - tile_size
	elif(previous_input_direction.y < 0):#moving up
		var y_remainder = fmod(position.y, tile_size)
		stopper.position.y = position.y - y_remainder - tile_size
	elif(previous_input_direction.y > 0):#moving down
		var bottom_edge = position.y + tile_size
		var y_remainder = fmod(bottom_edge, tile_size)
		stopper.position.y = bottom_edge - y_remainder + tile_size
			
	get_parent().add_child(stopper)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
