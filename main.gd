extends Node2D

@export var num_bubbles: int = 6
@export var obstacle_spawn_interval: float = 1.0
@export var obstacle_scene = preload("res://Obstacle.tscn")

@onready var bubble_scene = preload("res://Bubble.tscn")
@onready var score_label = $ScoreLabel  # Access the ScoreLabel node
@onready var high_score_label = $HighScoreLabel  # Add a label to display high score
@onready var reset_button = $ResetButton  # Access the ResetButton node
@onready var bubble_manager = $BubbleManager  # Access the BubbleManager node
@onready var ui_manager = $UIManager  # Access the UIManager node
@onready var obstacle_manager = $ObstacleManager  # Access the ObstacleManager node

@export var spawn_rate_increase_interval: float = 10.0  # Time in seconds to increase the spawn rate
@export var spawn_rate_increase_factor: float = 0.9  # Factor to decrease the spawn interval

@export var high_score_file_path: String = "user://high_score.save"  # File path for saving high score

@export var left_key_textures: Array[Texture2D]  # Array of left key textures
@export var right_key_textures: Array[Texture2D]  # Array of right key textures


var obstacle_timer = 0.0
var spawn_rate_timer = 0.0
var bubbles = []
var total_score = 0
var high_score = 0  # Variable to store the high score


var bubble_keys = [
	{"move_left_key": "move_left_2", "move_right_key": "move_right_2"},  # Q and E
	{"move_left_key": "ui_left", "move_right_key": "ui_right"},  # A and D
	{"move_left_key": "move_left_3", "move_right_key": "move_right_3"},  # Z and C
	{"move_left_key": "move_left_4", "move_right_key": "move_right_4"},  # I and P
	{"move_left_key": "move_left_5", "move_right_key": "move_right_5"},  # J and L
	{"move_left_key": "move_left_6", "move_right_key": "move_right_6"}   # N and ,
]

func _ready():
	load_high_score()  # Load high score at the start
	ui_manager.update_high_score_label(high_score_label, high_score)  # Display the loaded high score
	
	ui_manager.center_score_label(score_label)

	bubble_manager.initialize_bubbles(self, num_bubbles, bubble_keys, left_key_textures, right_key_textures)
	
	ui_manager.setup_reset_button(reset_button, self)

	ui_manager.update_score_label(score_label, total_score)  # Initial score display

func _process(delta: float):
	obstacle_timer += delta
	spawn_rate_timer += delta
	
	if obstacle_timer >= obstacle_spawn_interval:
		spawn_obstacle()
		obstacle_timer = 0.0

	if spawn_rate_timer >= spawn_rate_increase_interval:
		obstacle_spawn_interval *= spawn_rate_increase_factor  # Decrease the spawn interval to increase spawn rate
		spawn_rate_timer = 0.0
		print("Increased obstacle spawn rate, new interval: ", obstacle_spawn_interval)

	# Continuously update the score from all alive bubbles
	#total_score = 0
	for bubble in bubbles:
		if is_instance_valid(bubble) and bubble.alive:
			total_score += bubble.get_score()
	ui_manager.update_score_label(score_label, total_score)  # Update the score display

	# Check for game over condition
	if bubbles.is_empty():
		game_over()

func spawn_obstacle():
	var obstacle_instance = obstacle_scene.instantiate()
	var screen_size = get_viewport().size
	obstacle_instance.position = Vector2(randf_range(0, screen_size.x), 0)
	add_child(obstacle_instance)
	obstacle_instance.name = "Obstacle"  # Explicitly set the name after adding to the scene

func _on_bubble_popped(bubble_instance):
	bubble_manager.handle_bubble_popped(bubbles, bubble_instance)

	if bubbles.is_empty():
		game_over()

func save_high_score():
	var file = FileAccess.open(high_score_file_path, FileAccess.WRITE)
	if file:
		file.store_line(str(high_score))
		file.close()

func load_high_score():
	var file = FileAccess.open(high_score_file_path, FileAccess.READ)
	if file:
		if not file.eof_reached():
			high_score = file.get_line().to_int()
		file.close()

func game_over():
	print("Game Over! Final Score: ", total_score)
	if total_score > high_score:
		high_score = total_score
		save_high_score()  # Save the new high score
		ui_manager.update_high_score_label(high_score_label, high_score)  # Update the high score display
	ui_manager.display_game_over(score_label)
	ui_manager.show_reset_button(reset_button)
	set_process(false)  # Stop processing in the main script
	
func _on_ResetButton_pressed():
	reset_game()

func reset_game():
	print("Resetting game...")
	ui_manager.hide_reset_button(reset_button)  # Hide the reset button

	# Reset game variables
	total_score = 0
	obstacle_timer = 0.0
	spawn_rate_timer = 0.0
	obstacle_spawn_interval = 1.0

	# Clear existing bubbles and obstacles
	for bubble in bubbles:
		if is_instance_valid(bubble):
			bubble.queue_free()
	bubbles.clear()

	for child in get_children():
		if child.name.begins_with("Obstacle"):
			child.queue_free()

	# Reinitialize the bubbles
	bubble_manager.initialize_bubbles(self, num_bubbles, bubble_keys)

	set_process(true)  # Restart processing in the main script
	ui_manager.update_score_label(score_label, total_score)  # Reset the score label
