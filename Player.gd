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
	TURNING,
	IDLE
}
const stateFunctions = {
	PlayerStates.WALKING: "walk",
	PlayerStates.STOPPING: "stop",
	PlayerStates.TURNING: "turn",
	PlayerStates.IDLE: "idle"
}
var player_state = PlayerStates.IDLE
var queued_state = null

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("N")
onready var animationPlayer = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	print("ready")
	animation_tree.active = true
	animation_tree.set("parameters/Idle/blend_position", Vector2(0,1))
	animation_state.travel("Idle")
	print(animation_state.get_current_play_position())
	stopperClass = load("res://MovementStopper.tscn")

	
func _physics_process(delta):
	process_input()
	call(stateFunctions[player_state], delta)

func set_state(state):
	player_state = state

func set_queued_state():
	if queued_state != null:
		player_state = queued_state
		queued_state = null

func process_input():
	if input_direction.y == 0:
		input_direction.x = int(Input.get_action_strength("ui_right")) - int(Input.get_action_strength("ui_left"))
	if input_direction.x == 0:
		input_direction.y = int(Input.get_action_strength("ui_down")) - int(Input.get_action_strength("ui_up"))

	if input_direction != Vector2.ZERO and player_state != PlayerStates.STOPPING:
		animation_tree.set("parameters/Walk/blend_position", input_direction)
		animation_tree.set("parameters/Idle/blend_position", input_direction)
		animation_tree.set("parameters/Turn/blend_position", input_direction)		
		if input_direction != previous_input_direction:
			player_state = PlayerStates.TURNING
		elif player_state != PlayerStates.TURNING:
			player_state = PlayerStates.WALKING
		previous_input_direction = input_direction
	elif player_state == PlayerStates.WALKING:
		#player has released the walking action
		add_stopper()
		player_state = PlayerStates.STOPPING

func walk(delta):
	if animation_state.get_current_node() != "Walk":
		animation_state.travel("Walk")
	var result = move_and_collide(input_direction * walk_speed * delta)
		
func stop(delta):
	var result = move_and_collide(previous_input_direction * walk_speed * delta)	
	if result:
		stopper.queue_free();
		player_state = PlayerStates.IDLE

func idle(delta):
	if animation_state.get_current_node() != "Idle":
		animation_state.travel("Idle")
	pass

func turn(delta):
	if animation_state.get_current_node() != "Turn":
		animation_state.travel("Turn")
	queued_state = PlayerStates.IDLE
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
