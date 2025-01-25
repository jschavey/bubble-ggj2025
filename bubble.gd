extends Area2D

@export var move_left_key: String
@export var move_right_key: String
@export var bubble_size: Vector2 = Vector2(64, 64)  # Adjust the bubble size

var spawn_region: Rect2
var score: float = 0.0  # Use float for more precise score calculation
var alive: bool = true

@onready var sprite = get_node("../Sprite2D")  # Access the sibling Sprite2D node
@onready var collision_shape = $CollisionShape2D  # Access the CollisionShape2D node

signal bubble_popped(area2d)

var left_label: Label
var right_label: Label

func _ready():
	# Create left and right labels programmatically
	left_label = Label.new()
	left_label.scale = Vector2(2,2)
	add_child(left_label)
	
	right_label = Label.new()
	right_label.scale = Vector2(2,2)
	add_child(right_label)
	
	# Get the actual key names from InputMap
	left_label.text = get_key_from_action(move_left_key).to_upper()
	right_label.text = get_key_from_action(move_right_key).to_upper()

	randomize_position()
	scale_bubble()
	set_process(true)  # Ensure _process is enabled
	connect("area_entered", Callable(self, "_on_Bubble_area_entered"))  # Connect the area_entered signal
	
	update_labels_position()  # Initial label positioning

func _process(delta: float) -> void:
	if Input.is_action_pressed(move_left_key) and alive:
		global_position.x -= 250 * delta
	elif Input.is_action_pressed(move_right_key) and alive:
		global_position.x += 250 * delta
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_shape.global_position = global_position  # Ensure the collision shape moves with the Area2D
	if alive:
		score += delta  # Update score continuously while bubble is alive
	update_labels_position()  # Update the labels' positions

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
				emit_signal("bubble_popped", self)
				queue_free()  # Remove the bubble upon collision

func randomize_position():
	var x = randf_range(spawn_region.position.x, spawn_region.position.x + spawn_region.size.x)
	var y = randf_range(spawn_region.position.y, spawn_region.position.y + spawn_region.size.y)
	global_position = Vector2(x, y)  # Set the global position directly
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_shape.global_position = global_position  # Ensure the collision shape moves with the Area2D
	update_labels_position()  # Update the labels' positions

func scale_bubble():
	sprite.scale = bubble_size / sprite.texture.get_size()
	update_collision_shape()

func update_collision_shape():
	var shape = CircleShape2D.new()  # Initialize as CircleShape2D
	shape.radius = (sprite.texture.get_size().x * sprite.scale.x) / 2  # Adjust the radius based on the texture
	collision_shape.shape = shape  # Assign the shape to the collision_shape

func update_labels_position():
	left_label.global_position = global_position + Vector2(-bubble_size.x / 2 - 20, 0)  # Position to the left of the bubble
	right_label.global_position = global_position + Vector2(bubble_size.x / 2 + 20, 0)  # Position to the right of the bubble

func get_key_from_action(action: String) -> String:
	var key_events = InputMap.action_get_events(action)
	for event in key_events:
		if event is InputEventKey:
			return event.as_text_physical_keycode()
	return action

func get_score() -> int:
	return score
