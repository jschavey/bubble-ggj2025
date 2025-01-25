extends Node2D

@export var num_bubbles: int = 6
@export var obstacle_spawn_interval: float = 1.0
@export var obstacle_scene = preload("res://Obstacle.tscn")

@onready var bubble_scene = preload("res://Bubble.tscn")
@onready var score_label = $ScoreLabel  # Access the ScoreLabel node

@export var spawn_rate_increase_interval: float = 10.0  # Time in seconds to increase the spawn rate
@export var spawn_rate_increase_factor: float = 0.8  # Factor to decrease the spawn interval


var obstacle_timer = 0.0
var spawn_rate_timer = 0.0
var bubbles = []
var total_score = 0

var bubble_keys = [
	{"move_left_key": "move_left_2", "move_right_key": "move_right_2"},  # Q and E
	{"move_left_key": "ui_left", "move_right_key": "ui_right"},  # A and D
	{"move_left_key": "move_left_3", "move_right_key": "move_right_3"},  # Z and C
	{"move_left_key": "move_left_4", "move_right_key": "move_right_4"},  # I and P
	{"move_left_key": "move_left_5", "move_right_key": "move_right_5"},  # J and L
	{"move_left_key": "move_left_6", "move_right_key": "move_right_6"}   # N and ,
]

func _ready():
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
		area2d_instance.connect("area_entered", Callable(self, "_on_Bubble_area_entered"))

	update_score_label()  # Initial score display

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

func _on_Bubble_area_entered(area: Area2D):
	print("Collision detected with: ", area.name)  # Log the collision
	if area.get_parent().name == "Obstacle":
		print("Collided with Obstacle")
		area.queue_free()
		bubbles.erase(area)
		if bubbles.is_empty():
			game_over()

func update_score_label():
	score_label.text = "Score: " + str(total_score)  # Update the score label text

func game_over():
	print("Game Over! Final Score: ", total_score)
	score_label.text += "\nGame Over!"  # Display game over message
	set_process(false)  # Stop processing in the main script
