extends Area2D

@export var obstacle_textures: Array[Texture2D]
@export var obstacle_size: Vector2 = Vector2(192, 192)  # Adjust the obstacle size
@export var speed: float = 350.0

@onready var sprite = get_parent().get_node('Sprite2D')  # Access the sibling Sprite2D node
@onready var collision_polygon = $CollisionPolygon2D  # Access the CollisionPolygon2D node

func _ready():
	randomize_appearance()
	generate_collision_shape()
	scale_both()
	apply_rotation()
	set_process(true)  # Ensure _process is enabled

func _process(delta: float):
	move_obstacle(delta)

func randomize_appearance():
	var texture = obstacle_textures[randi() % obstacle_textures.size()]
	sprite.texture = texture

func move_obstacle(delta: float):
	global_position.y += speed * delta
	sprite.global_position = global_position  # Ensure the sprite moves with the Area2D
	collision_polygon.global_position = global_position  # Ensure the collision polygon moves with the Area2D
	if global_position.y > get_viewport_rect().size.y:
		queue_free()

func generate_collision_shape():
	var image = sprite.texture.get_image()
	if image:
		var points = []
		var center_offset = sprite.texture.get_size() / 2  # Center offset

		for y in range(image.get_height()):
			for x in range(image.get_width()):
				if image.get_pixel(x, y).a > 0.5:  # Check alpha value
					points.append(Vector2(x, y) - center_offset)

		# Create a convex polygon from the points
		var convex_points = Geometry2D.convex_hull(points)

		collision_polygon.polygon = convex_points
	else:
		print("Failed to convert texture to image")

func scale_both():
	var original_size = sprite.texture.get_size()
	var scale_factor = obstacle_size / original_size
	sprite.scale = scale_factor
	collision_polygon.scale = scale_factor

func apply_rotation():
	var rand_rotation = randi() % 360
	sprite.rotation_degrees = rand_rotation
	collision_polygon.rotation_degrees = rand_rotation
