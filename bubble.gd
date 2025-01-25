extends Area2D

@export var move_left_key: String
@export var move_right_key: String
@export var bubble_size: Vector2 = Vector2(64, 64)  # Adjust the bubble size

var spawn_region: Rect2
var score: float = 0
var alive: bool = true

@onready var sprite = get_node("../Sprite2D")  # Access the sibling Sprite2D node
@onready var collision_shape = $CollisionShape2D  # Access the CollisionShape2D node

func _ready():
	randomize_position()
	scale_bubble()
	set_process(true)  # Ensure _process is enabled
	connect("area_entered", Callable(self, "_on_Bubble_area_entered"))  # Connect the area_entered signal

func _process(delta: float) -> void:
	if Input.is_action_pressed(move_left_key) and alive:
		global_position.x -= 250 * delta
	elif Input.is_action_pressed(move_right_key) and alive:
		global_position.x += 250 * delta
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_shape.global_position = global_position  # Ensure the collision shape moves with the Area2D
	if alive:
		score += delta  # Update score continuously while bubble is alive

	# Manual collision detection (for comparison)
	var colliding_areas = get_overlapping_areas()
	for area in colliding_areas:
		print("Manual collision detected with: ", area.name)
		if area.get_parent() and area.get_parent().name.begins_with("Obstacle"):
			print("Manual collision with Obstacle")
			alive = false
			sprite.visible = false  # Hide the sprite immediately
			queue_free()

func _on_Bubble_area_entered(area: Node):
	print("Collision detected with: ", area.name)  # Log the collision
	if area is Area2D:
		print("Collided with Area2D node")
		if area.get_parent():
			print("Parent name: ", area.get_parent().name)  # Log the parent name
			if area.get_parent().name.begins_with("Obstacle"):
				print("Collided with Obstacle")
				alive = false
				sprite.visible = false  # Hide the sprite immediately
				queue_free()  # Remove the bubble upon collision

func randomize_position():
	var x = randf_range(spawn_region.position.x, spawn_region.position.x + spawn_region.size.x)
	var y = randf_range(spawn_region.position.y, spawn_region.position.y + spawn_region.size.y)
	global_position = Vector2(x, y)  # Set the global position directly
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_shape.global_position = global_position  # Ensure the collision shape moves with the Area2D

func scale_bubble():
	sprite.scale = bubble_size / sprite.texture.get_size()
	update_collision_shape()

func update_collision_shape():
	var shape = CircleShape2D.new()  # Initialize as CircleShape2D
	shape.radius = (sprite.texture.get_size().x * sprite.scale.x) / 2  # Adjust the radius based on the texture
	collision_shape.shape = shape  # Assign the shape to the collision_shape

func get_score() -> int:
	return score
