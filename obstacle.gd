extends Area2D

@export var obstacle_textures: Array[Texture2D]
@export var obstacle_size: Vector2 = Vector2(256, 256)  # Adjust the obstacle size
@export var speed: float = 200.0

@onready var sprite = get_node("../Sprite2D")  # Access the sibling Sprite2D node
@onready var collision_shape = $CollisionShape2D  # Access the CollisionShape2D node

func _ready():
	randomize_appearance()
	scale_obstacle()
	set_process(true)  # Ensure _process is enabled

func _process(delta: float):
	move_obstacle(delta)

func randomize_appearance():
	var texture = obstacle_textures[randi() % obstacle_textures.size()]
	sprite.texture = texture
	sprite.rotation_degrees = randi() % 360
	scale_obstacle()

func move_obstacle(delta: float):
	global_position.y += speed * delta
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_shape.position = Vector2.ZERO  # Center the collision shape
	if global_position.y > get_viewport_rect().size.y:
		queue_free()

func scale_obstacle():
	sprite.scale = obstacle_size / sprite.texture.get_size()
	update_collision_shape()

func update_collision_shape():
	var shape = collision_shape.shape as RectangleShape2D
	shape.extents = sprite.texture.get_size() * sprite.scale / 2# Adjust the size based on the texture
