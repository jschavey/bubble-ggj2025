extends Node2D

@export var num_bubbles: int = 6
@export var obstacle_spawn_interval: float = 1.0
@export var obstacle_scene = preload("res://Obstacle.tscn")

@onready var bubble_scene = preload("res://Bubble.tscn")
@onready var score_label = $ScoreLabel  # Access the ScoreLabel node
@onready var high_score_label = $HighScoreLabel  # Add a label to display high score
@onready var reset_button = $ResetButton  # Access the ResetButton node


@export var spawn_rate_increase_interval: float = 10.0  # Time in seconds to increase the spawn rate
@export var spawn_rate_increase_factor: float = 0.8  # Factor to decrease the spawn interval

@export var high_score_file_path: String = "user://high_score.save"  # File path for saving high score


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
	update_high_score_label()  # Display the loaded high score
	
	center_score_label()

	var screen_size = get_viewport().size
	var regions = [
		Rect2(Vector2(0, 0), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Top left (Q and E)
		Rect2(Vector2(0, screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Middle left (A and D)
		Rect2(Vector2(0, 2 * screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Bottom left (Z and C)
		Rect2(Vector2(screen_size.x / 2, 0), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Top right (I and P)
		Rect2(Vector2(screen_size.x / 2, screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Middle right (J and L)
		Rect2(Vector2(screen_size.x / 2, 2 * screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3))  # Bottom right (N and ,)
	]

	for i in range(min(num_bubbles, 6)):
		var bubble_instance = bubble_scene.instantiate()
		var area2d_instance = bubble_instance.get_child(0)  # Assuming the first child is the Area2D node
		area2d_instance.move_left_key = bubble_keys[i]["move_left_key"]
		area2d_instance.move_right_key = bubble_keys[i]["move_right_key"]
		area2d_instance.spawn_region = regions[i]
		add_child(bubble_instance)
		bubbles.append(area2d_instance)
		area2d_instance.connect("bubble_popped", Callable(self, "_on_bubble_popped"))  # Connect to bubble_popped signal

	reset_button.connect("pressed", Callable(self, "_on_ResetButton_pressed")) # Connect the reset button
	reset_button.visible = false  # Initially hide the reset button

	update_score_label()  # Initial score display
	
func center_score_label():
	var screen_width = get_viewport().size.x
	var label_width = score_label.size.x
	score_label.position.x = (screen_width - label_width) / 2

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
	update_score_label()  # Update the score display

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
	print("Bubble popped: ", bubble_instance)
	bubbles.erase(bubble_instance)  # Remove the bubble from the array

	if bubbles.is_empty():
		game_over()

func update_score_label():
	score_label.text = "Score: " + str(total_score)  # Update the score label text
	
func update_high_score_label():
	high_score_label.text = "High Score: " + str(high_score)  # Update the high score label text

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
		update_high_score_label()  # Update the high score display
	score_label.text += "\nGame Over!"  # Display game over message
	reset_button.visible = true  # Show the reset button
	set_process(false)  # Stop processing in the main script
	
func _on_ResetButton_pressed():
	reset_game()

func reset_game():
	print("Resetting game...")
	reset_button.visible = false  # Hide the reset button

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
	var screen_size = get_viewport().size
	var regions = [
		Rect2(Vector2(0, 0), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Top left (Q and E)
		Rect2(Vector2(0, screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Middle left (A and D)
		Rect2(Vector2(0, 2 * screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Bottom left (Z and C)
		Rect2(Vector2(screen_size.x / 2, 0), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Top right (I and P)
		Rect2(Vector2(screen_size.x / 2, screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3)),  # Middle right (J and L)
		Rect2(Vector2(screen_size.x / 2, 2 * screen_size.y / 3), Vector2(screen_size.x / 2, screen_size.y / 3))  # Bottom right (N and ,)
	]

	for i in range(min(num_bubbles, 6)):
		var bubble_instance = bubble_scene.instantiate()
		var area2d_instance = bubble_instance.get_child(0)  # Assuming the first child is the Area2D node
		area2d_instance.move_left_key = bubble_keys[i]["move_left_key"]
		area2d_instance.move_right_key = bubble_keys[i]["move_right_key"]
		area2d_instance.spawn_region = regions[i]
		add_child(bubble_instance)
		bubbles.append(area2d_instance)
		area2d_instance.connect("bubble_popped", Callable(self, "_on_bubble_popped"))  # Connect to bubble_popped signal

	set_process(true)  # Restart processing in the main script
	update_score_label()  # Reset the score label
